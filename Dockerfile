# Use a build-time argument to specify the PHP version. Defaulting to 8.4
ARG PHP_VERSION=8.4
# Use a build-time argument to specify the Node.js version. Defaulting to 24.
ARG NODE_VERSION=24

# ==> 1. Builder Stage <==
# This stage compiles a custom FrankenPHP binary with specific Caddy modules.
FROM dunglas/frankenphp:builder-php${PHP_VERSION}-bookworm AS builder

# Copy xcaddy from the official Caddy builder image
COPY --from=caddy:2.11.4-builder /usr/bin/xcaddy /usr/bin/xcaddy

# CGO must be enabled to build FrankenPHP with custom modules
# We use xcaddy to build a new binary including the specified plugins.
RUN CGO_ENABLED=1 \
    XCADDY_SETCAP=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
    CGO_CFLAGS=$(php-config --includes) \
    CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
    xcaddy build \
        --output /usr/local/bin/frankenphp \
        --with github.com/dunglas/frankenphp=./ \
        --with github.com/dunglas/frankenphp/caddy=./caddy/ \
        --with github.com/dunglas/caddy-cbrotli \
        --with github.com/dunglas/mercure/caddy \
        --with github.com/dunglas/vulcain/caddy \
        --with github.com/caddy-dns/vultr \
        --with github.com/caddy-dns/azure \
        --with github.com/caddy-dns/googleclouddns \
        --with github.com/caddy-dns/digitalocean \
        --with github.com/caddy-dns/cloudflare \
        --with github.com/caddy-dns/route53 \
        --with github.com/darkweak/souin/plugins/caddy \
        --with github.com/darkweak/storages/go-redis/caddy \
        --with github.com/darkweak/storages/otter/caddy \
        --with github.com/darkweak/storages/simplefs/caddy
# ==> 2. Runner Stage <==
# This is the final image. It uses the custom binary from the builder stage.
FROM dunglas/frankenphp:php${PHP_VERSION}-bookworm AS runner

# Copy the custom-built FrankenPHP binary from the builder stage
COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp

# Re-declare ARGs to be available in subsequent build stages
ARG PHP_VERSION
ARG NODE_VERSION

# ==> 3. Install System Dependencies & Node.js <==
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        default-mysql-client \
        git \
        gosu \
        netcat-openbsd \
        procps \
        unzip \
        zip \
        cron \
        supervisor \
        ffmpeg; \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*

# ==> 4. Install PHP Extensions <==
COPY --from=ghcr.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
COPY scripts/install-extensions.sh /usr/local/bin/
COPY data/installable-extensions /tmp/
COPY data/supported-extensions /tmp/
RUN chmod +x /usr/local/bin/install-extensions.sh && \
    IPE_ICU_EN_ONLY=1 install-extensions.sh ${PHP_VERSION} && \
    rm /tmp/installable-extensions /tmp/supported-extensions

# ==> 5. Install Global PHP Tools <==
COPY --from=composer:2.10.1 /usr/bin/composer /usr/local/bin/composer
ADD --chmod=0755 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp

# ==> 6. Configure PHP <==
# Use the production php.ini configuration file
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# ==> 7. Final Setup <==
WORKDIR /app
EXPOSE 80 443 443/udp

# Default command to run FrankenPHP, expecting a user-provided Caddyfile
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
