# Contributing

Thanks for your interest in improving these Docker images!

## How to Contribute

### Request a New Extension
1. Open an issue with the title `Extension request: <name>`
2. Check that the extension is [supported upstream](https://github.com/mlocati/docker-php-extension-installer/blob/master/data/supported-extensions)
3. Mention which PHP versions you need it for

### Request a New Caddy Module
1. Open an issue with the title `Module request: <name>`
2. Provide the Go module path (e.g., `github.com/org/repo`)
3. Explain the use case — why should it be included for everyone?

### Report a Bug
1. Open an issue with details: image tag, error message, steps to reproduce
2. If the bug is about a missing extension, include `php -m` output

### Submit a Pull Request
1. Fork the repo and create a feature branch
2. Make your changes — keep them focused and minimal
3. Test locally:
   ```bash
   docker build -t test-image .
   docker run --rm test-image php -m
   ```
4. Open a PR against `main` with a clear description

## Project Structure

```
.
├── Dockerfile                    # Main image definition
├── EXTENSIONS.md                 # Every extension and tool, with versions (update it when the lists change)
├── data/
│   ├── installable-extensions    # Extensions we want to install
│   └── supported-extensions      # Upstream compatibility matrix (synced in CI from the pinned installer release)
├── scripts/
│   ├── install-extensions.sh     # Extension filtering and install script
│   └── check-upstream.sh         # Compares the pinned versions with upstream
├── php.ini.example               # Example hardened PHP config (copy to php.ini and mount)
└── .github/workflows/            # CI/CD pipeline
```

## Keeping the pins current

`scripts/check-upstream.sh` compares every version pinned in the `Dockerfile` with
the latest upstream release: FrankenPHP and Caddy (GitHub releases), the Caddy
builder image digest (Docker Hub), the PHP security floors (php.net; only a newer
security release counts), Node.js in the `NODE_VERSION` line (nodejs.org), npm (the
npm registry), Composer, WP-CLI and the PHP extension installer (GitHub releases),
and each `--with` Caddy plugin (the Go module proxy). It exits non-zero and lists
what is behind. The `Upstream check` workflow runs it every Monday and can be run
by hand; it changes nothing, so moving a pin is still a commit of its own. Run it
locally with `bash scripts/check-upstream.sh` (set `GITHUB_TOKEN` to avoid the
GitHub API's anonymous rate limit). Dependabot moves the workflow actions.

## Code Style
- Keep the Dockerfile readable with clear section headers
- Shell scripts use `#!/bin/bash` with `set -e`
- Extensions in `installable-extensions` are one per line, alphabetized
