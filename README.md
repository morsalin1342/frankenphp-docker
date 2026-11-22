# FrankenPHP Docker Images with a Custom Caddy Build

[![Docker Pulls](https://img.shields.io/docker/pulls/morsalin1342/frankenphp.svg?style=for-the-badge&logo=docker)](https://hub.docker.com/r/morsalin1342/frankenphp)
[![GitHub Stars](https://img.shields.io/github/stars/morsalin1342/frankenphp-docker?style=for-the-badge&logo=github)](https://github.com/morsalin1342/frankenphp-docker)
[![License](https://img.shields.io/github/license/morsalin1342/frankenphp-docker?style=for-the-badge)](https://github.com/morsalin1342/frankenphp-docker/blob/master/LICENSE)
[![Docker Publish](https://github.com/morsalin1342/frankenphp-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/morsalin1342/frankenphp-docker/actions/workflows/docker-publish.yml)

This repository contains the build instructions for a set of customized **FrankenPHP** Docker images, for PHP 8.2 to 8.5. They are built on the official `dunglas/frankenphp` base, with the `frankenphp` binary recompiled to add Caddy plugins (Coraza WAF, rate limiting, Brotli, Souin cache, 6 DNS providers), 51 PHP extensions on top of the base image's (counted on PHP 8.5), and Composer, WP-CLI, Node.js and the MariaDB client.

The images are built and published to [Docker Hub](https://hub.docker.com/r/morsalin1342/frankenphp) by GitHub Actions: on a push to `master`, and once a week so PHP patch releases and Debian's security updates are picked up. A build that has a fixable critical vulnerability is not pushed.

**Platform:** linux/amd64 only. `morsalin1342/frankenphp` and `easydigital/frankenphp` are the same image, pushed by the same build with the same digest; pull whichever you prefer.

## ✨ Why This Image?

| Feature | Official `dunglas/frankenphp` | This Image |
|---------|-------------------------------|------------|
| **Caddy modules** | Minimal | 16 plugins (Coraza WAF, rate limiting, Brotli, Souin cache, 6 DNS providers) |
| **Web application firewall** | ❌ | ✅ OWASP Coraza + Core Rule Set (compiled in) |
| **PHP extensions** | 35 loaded on PHP 8.5 | 51 more installed on PHP 8.5 (Redis, MongoDB, Imagick, PostgreSQL, OpenTelemetry, etc.) |
| **Composer** | ❌ | ✅ 2.11.2 |
| **WP-CLI** | ❌ | ✅ 2.12.0 |
| **Node.js** | ❌ | ✅ v24 (configurable) |
| **MariaDB client** | ❌ | ✅ `mariadb` tools, also as `mysql`, `mysqldump` |

## Quick Start

FrankenPHP is a self-contained application server, so you don't need a separate web server like Nginx. The easiest way to get started is with a `docker-compose.yml` file.

Here is an example serving a simple application:

```yaml
# docker-compose.yml
services:
  frankenphp:
    # Replace with your desired PHP version tag
    image: morsalin1342/frankenphp:8.4
    ports:
      - "80:80"      # HTTP
      - "443:443"    # HTTPS
      - "443:443/udp"# HTTP/3
    volumes:
      # Mount your application code
      - ./public:/app
      # Mount your custom Caddyfile
      - ./Caddyfile:/etc/caddy/Caddyfile
```

You must provide a `Caddyfile` to tell FrankenPHP how to serve your application. Create a `Caddyfile` in your project root:

```caddy
# Caddyfile
:80 {
    # Set the root to your app's public directory
    root * /app
    # Enable compression
    encode zstd gzip
    # Route all requests to the PHP server
    php_server
    # Serve static files if they exist
    file_server
}
```

Finally, create a `public/index.php` file and run `docker-compose up` to start the services.

## Available Versions

This project builds and maintains images for the following PHP versions:

*   **8.5** (Also tagged as `latest`)
*   **8.4**
*   **8.3**
*   **8.2**

### Tagging Strategy

Each image is tagged with multiple schemes for flexibility:

*   `morsalin1342/frankenphp:latest`: Always points to the most recent build of the PHP 8.5 image.
*   `morsalin1342/frankenphp:<version>` (e.g., `morsalin1342/frankenphp:8.4`): A convenient tag for a specific major version.
*   `morsalin1342/frankenphp:<version>-trixie` (e.g., `morsalin1342/frankenphp:8.4-trixie`): The same image with the base OS in the tag (Debian 13).

Every PHP version is built on Debian 13 (trixie) only. bookworm is built again only for a PHP version whose base image has no trixie variant. The old `-bookworm` tags stay on Docker Hub but are no longer updated.

It is recommended to use a specific version tag (like `8.4-trixie`) in production environments for stability.

## Included Extensions & Utilities

These images come with a wide range of pre-installed components to minimize setup time.

### Custom Caddy Modules

The `frankenphp` binary is custom-compiled with the following additional Caddy modules:

*   **coraza** (v2.6.2): OWASP Coraza WAF — ModSecurity/SecLang compatible, with the OWASP Core
    Rule Set compiled into the binary. Use `load_owasp_crs` and the `@`-prefixed include
    paths; there are no rule files to download or mount. Requires `order coraza_waf first`
    in the global options.
*   **defender** (v0.10.1): IP-range blocking for AI crawlers, cloud provider ranges and custom
    CIDRs. Module path is the vanity import `pkg.jsn.cam/caddy-defender`.
*   **rate_limit** (v0.1.0): Sliding-window rate limiting, multiple zones, keyed on any request
    placeholder. Ordered before `basic_auth` by default.
*   **cbrotli** (v1.0.1): Brotli compression support.
*   **souin** (v1.7.9): HTTP Cache.
*   **DNS Challenge Providers**: `vultr`, `azure`, `googleclouddns`, `digitalocean`, `cloudflare`, `route53`.
*   **Souin Storage Providers** (v0.0.20): `go-redis`, `otter`, `simplefs`.

FrankenPHP is 1.13.6 on Caddy 2.11.9. Every module is pinned to an explicit version in the `Dockerfile`; the exact versions are listed in [EXTENSIONS.md](EXTENSIONS.md).

### PHP Extensions

**Every extension, Caddy module and tool, with its version and what it does, is listed in [EXTENSIONS.md](EXTENSIONS.md)**, including known issues (for example, `timezonedb` and `http` crash a configuration reload).

| Category         | Extensions                                                                    |
|------------------|-------------------------------------------------------------------------------|
| **Performance**  | `apcu`, `igbinary`, `memcached`, `opcache`, `redis`                             |
| **Asynchronous** | `pcntl`, `sockets`                                                |
| **Databases**    | `mongodb`, `mysqli`, `pdo_mysql`, `pdo_pgsql`, `pgsql`                                   |
| **Utilities**    | `bcmath`, `brotli`, `bz2`, `calendar`, `csv`, `ds`, `enchant`, `exif`, `ffi`, `ftp`, `gd`, `gettext`, `gmp`, `gnupg`, `http`, `imagick`, `inotify`, `intl`, `ldap`, `mailparse`, `mcrypt`, `oauth`, `pspell`, `shmop`, `soap`, `ssh2`, `tidy`, `timezonedb`, `uuid`, `xmlrpc`, `xsl`, `yaml`, `zip`, `zstd` |
| **Observability**| `opentelemetry`                                                                |

### Command-Line Utilities

*   **Composer** 2.11.2: the PHP dependency manager.
*   **WP-CLI** 2.12.0: the command-line tool for WordPress.
*   **Node.js**: v24.x, for frontend asset compilation and other tasks.
*   **MariaDB client**: `mariadb`, `mariadb-dump` and the rest, also linked as `mysql` and `mysqldump`.
*   **Not included**: `supervisor` and `cron`; run workers and schedulers as separate containers.
*   **Other Tools**: `curl`, `gosu`, `unzip`, `zip`, `ffmpeg`.

## Configuration

*   The images use PHP's `php.ini-production`. The repository also carries a stricter example, [`php.ini.example`](php.ini.example), with `open_basedir` restrictions, disabled dangerous functions and tighter limits. It is not applied by default: copy it to `php.ini` and mount it (see the FAQ).
*   The server is configured by mounting a custom `Caddyfile` to `/etc/caddy/Caddyfile` inside the container.

## ❓ FAQ

**Q: Can I run custom php.ini configurations?**
A: Yes. Mount your own `php.ini` file into the container (start from [`php.ini.example`](php.ini.example)):
```yaml
    volumes:
      - ./php.ini:/usr/local/etc/php/php.ini:ro
```

**Q: How do I add extensions not in your list?**
A: The image includes `install-php-extensions` (from `mlocati/docker-php-extension-installer`), so another extension is one layer in your own `Dockerfile`:
```dockerfile
FROM morsalin1342/frankenphp:8.4
RUN install-php-extensions my-custom-extension
```

**Q: Why Node.js v24?**
A: Node.js 24 is a long-term-support line, maintained until 2028-04-30 according to the [Node.js release schedule](https://github.com/nodejs/Release). You can choose another major version at build time with the `NODE_VERSION` build arg, together with `NODE_PACKAGE_VERSION`, the exact NodeSource package of that line (for example `22.x.y-1nodesource1`).

**Q: How do I manage queues or background processes?**
A: Run them as separate containers from the same image with their own command; the images no longer include `supervisor` or `cron`.

**Q: How do I configure HTTPS with a custom domain?**
A: FrankenPHP's built-in Caddy server obtains TLS certificates automatically via Let's Encrypt. Specify your domain in the `Caddyfile` and ensure ports 80 and 443 are exposed.

---

## Licence

The files in this repository are MIT ([LICENSE](LICENSE)). That licence covers the build files,
not the software in the image, which keeps its own licences. The main components:

| Component | Licence |
|---|---|
| FrankenPHP | MIT |
| Caddy | Apache-2.0 |
| Coraza, coraza-caddy and the Core Rule Set compiled into it | Apache-2.0 |
| caddy-ratelimit | Apache-2.0 |
| caddy-defender, caddy-cbrotli, Souin and its storages | MIT |
| DNS providers: cloudflare | Apache-2.0 |
| DNS providers: route53, azure, googleclouddns | MIT |
| DNS providers: digitalocean, vultr | no licence file in their repositories at the pinned commits |
| PHP 8.2 to 8.5 | PHP-3.01 (the PHP License) |
| PHP extensions installed on top | each its own; PECL extensions vary |
| Composer, WP-CLI, Node.js | MIT (Node.js's bundled dependencies keep theirs) |
| npm | Artistic-2.0 |
| MariaDB client programs | GPL-2.0 |
| FFmpeg, as Debian builds it | GPL-2.0-or-later (Debian builds it with `--enable-gpl`) |
| Debian packages from the base image and `apt-get` | their own licences |

FrankenPHP's Mercure and Vulcain modules, which are AGPL-3.0, are left out of the build (the
Dockerfile explains how). Each build also writes an SPDX SBOM, kept as an artifact of its
workflow run, which lists each package with the licence it declares.

---

## Related Images & Tools

<!-- BEGIN GENERATED: related (from manifest/images.yaml in the morsalin1342/.github repository; do not edit by hand) -->
Every image is published under `morsalin1342` (personal) and `easydigital` (organization), from the same build.

| Repository | Images | Description |
|---|---|---|
| [caddy-docker](https://github.com/morsalin1342/caddy-docker) | `morsalin1342/caddy` · `easydigital/caddy` | Standalone Caddy with WAF, rate limiting & caching |
| [php-docker](https://github.com/morsalin1342/php-docker) | `morsalin1342/php` · `easydigital/php` | Traditional PHP-FPM & CLI images |
| [nginx-docker](https://github.com/morsalin1342/nginx-docker) | `morsalin1342/nginx` · `easydigital/nginx` | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 |
| [apache-docker](https://github.com/morsalin1342/apache-docker) | `morsalin1342/apache` · `easydigital/apache` | Apache as a static server or php-fpm application server, no PHP inside |
| [adminer-docker](https://github.com/morsalin1342/adminer-docker) | `morsalin1342/adminer` · `easydigital/adminer` | Adminer database tool: the official image plus Alpine security updates |
<!-- END GENERATED: related -->

---

## Feedback and Issues

If you have suggestions, find a bug, or want to request a new extension, please [open an issue](https://github.com/morsalin1342/frankenphp-docker/issues) on the GitHub repository.

---

⭐ **If this project helps you, consider giving it a star!**
