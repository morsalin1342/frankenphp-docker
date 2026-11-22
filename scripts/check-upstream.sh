#!/bin/bash
# Compare each version pinned in the Dockerfile with the latest upstream release,
# and exit non-zero, listing what is behind, if any pin is older.
#
# Checked:
#   FrankenPHP          FRANKENPHP_VERSION      GitHub releases of php/frankenphp
#   Caddy               CADDY_BUILDER_VERSION   GitHub releases of caddyserver/caddy
#   Caddy builder       CADDY_BUILDER_DIGEST    Docker Hub digest of caddy:<version>-builder
#   PHP 8.x floors      the "min=" lines        php.net releases JSON (security releases only)
#   Node.js             NODE_PACKAGE_VERSION    nodejs.org release index, NODE_VERSION line
#   npm                 NPM_VERSION             npm registry, "latest" tag
#   Composer            composer:<tag>          GitHub releases of composer/composer
#   WP-CLI              WP_CLI_VERSION          GitHub releases of wp-cli/wp-cli
#   extension installer php-extension-installer:<tag>  GitHub releases of mlocati/docker-php-extension-installer
#   Caddy plugins       --with <module>@<ver>   Go module proxy
#
# Needs bash, curl and jq. GITHUB_TOKEN, when set, is sent to the GitHub API to
# avoid its rate limit for anonymous requests.
#
# Usage: scripts/check-upstream.sh [path/to/Dockerfile]
set -euo pipefail

DOCKERFILE=${1:-Dockerfile}
GOPROXY_URL=${GOPROXY_URL:-https://proxy.golang.org}

behind=()
failed=()

fetch() {
    curl -fsSL --retry 3 --max-time 30 "$@"
}

github_latest() {
    local auth=()
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        auth=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    fetch "${auth[@]}" -H 'Accept: application/vnd.github+json' \
        "https://api.github.com/repos/$1/releases/latest" | jq -er '.tag_name'
}

# The Go module proxy escapes upper-case letters in module paths as !lower.
goproxy_latest() {
    local escaped
    escaped=$(printf '%s' "$1" | sed -E 's/([A-Z])/!\L\1/g')
    fetch "${GOPROXY_URL}/${escaped}/@latest" | jq -er '.Version'
}

# arg NAME: the default of "ARG NAME=value" in the Dockerfile.
arg() {
    grep -oP "^ARG $1=\K\S+" "$DOCKERFILE" | head -n 1
}

report() {
    printf '%-44s %-40s %s\n' "$1" "$2" "$3"
}

# compare NAME PINNED LATEST: record NAME as behind when LATEST sorts after PINNED.
compare() {
    local name=$1 pinned=$2 latest=$3
    if [ -z "$pinned" ]; then
        failed+=("$name")
        report "$name" "?" "(no pin found in $DOCKERFILE)"
    elif [ -z "$latest" ]; then
        failed+=("$name")
        report "$name" "$pinned" "(could not read the latest version)"
    elif [ "${pinned#v}" = "${latest#v}" ]; then
        report "$name" "$pinned" "up to date"
    elif [ "$(printf '%s\n%s\n' "${pinned#v}" "${latest#v}" | sort -V | tail -n 1)" = "${latest#v}" ]; then
        behind+=("$name $pinned -> $latest")
        report "$name" "$pinned" "BEHIND: $latest"
    else
        report "$name" "$pinned" "newer than the latest release ($latest)"
    fi
}

[ -f "$DOCKERFILE" ] || { echo "No $DOCKERFILE here." >&2; exit 2; }

compare "FrankenPHP" "$(arg FRANKENPHP_VERSION)" "$(github_latest php/frankenphp || true)"

caddy_version=$(arg CADDY_BUILDER_VERSION)
compare "Caddy" "$caddy_version" "$(github_latest caddyserver/caddy || true)"

# The builder image digest, against the digest its tag has now on Docker Hub.
pinned_digest=$(arg CADDY_BUILDER_DIGEST)
hub_digest=$(fetch "https://hub.docker.com/v2/repositories/library/caddy/tags/${caddy_version}-builder" | jq -er '.digest' || true)
if [ -z "$hub_digest" ] || [ -z "$pinned_digest" ]; then
    failed+=("caddy:${caddy_version}-builder digest")
    report "caddy:${caddy_version}-builder digest" "${pinned_digest:-?}" "(could not compare)"
elif [ "$pinned_digest" = "$hub_digest" ]; then
    report "caddy:${caddy_version}-builder digest" "${pinned_digest:0:19}" "up to date"
else
    behind+=("caddy:${caddy_version}-builder digest ${pinned_digest} -> ${hub_digest}")
    report "caddy:${caddy_version}-builder digest" "${pinned_digest:0:19}" "BEHIND: ${hub_digest:0:19}"
fi

# PHP security floors, from lines like "8.4) min=8.4.28 ;;". Only a newer release
# that php.net tags as a security release counts as behind.
while read -r branch floor; do
    json=$(fetch "https://www.php.net/releases/index.php?json&version=${branch}" || true)
    latest=$(printf '%s' "$json" | jq -r '.version // empty' 2>/dev/null || true)
    security=$(printf '%s' "$json" | jq -r '(.tags // []) | index("security") != null' 2>/dev/null || true)
    if [ -n "$latest" ] && [ "$latest" != "$floor" ] && [ "$security" != "true" ]; then
        report "PHP ${branch} floor" "$floor" "latest is $latest, not a security release"
    else
        compare "PHP ${branch} floor" "$floor" "$latest"
    fi
done < <(grep -oP '^\s*\K8\.[0-9]+\) min=8\.[0-9]+\.[0-9]+' "$DOCKERFILE" | sed -E 's/\) min=/ /')

# Node.js: the release in NODE_PACKAGE_VERSION (24.22.3-1nodesource1 -> 24.22.3)
# against the newest release of the NODE_VERSION line.
node_major=$(arg NODE_VERSION)
node_latest=$(fetch https://nodejs.org/dist/index.json \
    | jq -er --arg m "v${node_major}." '[.[] | select(.version | startswith($m))][0].version' || true)
node_pin=$(arg NODE_PACKAGE_VERSION)
compare "Node.js ${node_major}" "${node_pin%%-*}" "$node_latest"

compare "npm" "$(arg NPM_VERSION)" "$(fetch https://registry.npmjs.org/npm/latest | jq -er '.version' || true)"

compare "Composer" "$(grep -oP 'COPY --from=composer:\K[0-9][^@[:space:]]*' "$DOCKERFILE" | head -n 1)" \
    "$(github_latest composer/composer || true)"

compare "WP-CLI" "$(arg WP_CLI_VERSION)" "$(github_latest wp-cli/wp-cli || true)"

compare "php-extension-installer" \
    "$(grep -oP 'ghcr\.io/mlocati/php-extension-installer:\K[0-9][^@[:space:]]*' "$DOCKERFILE" | head -n 1)" \
    "$(github_latest mlocati/docker-php-extension-installer || true)"

# Caddy plugins: --with <module>@<version>; local replacements (=./) are skipped.
souin_version=$(arg SOUIN_VERSION)
while read -r module version; do
    version=${version//\$\{SOUIN_VERSION\}/$souin_version}
    compare "$module" "$version" "$(goproxy_latest "$module" || true)"
done < <(grep -oP -- '--with \K[^@=[:space:]]+@[^[:space:]\\]+' "$DOCKERFILE" | tr '@' ' ')

echo
if [ "${#failed[@]}" -gt 0 ]; then
    echo "Could not check: ${failed[*]}"
fi
if [ "${#behind[@]}" -gt 0 ]; then
    echo "Behind upstream:"
    printf '  %s\n' "${behind[@]}"
    exit 1
fi
if [ "${#failed[@]}" -gt 0 ]; then
    exit 2
fi
echo "Every pin is at the latest upstream release."
