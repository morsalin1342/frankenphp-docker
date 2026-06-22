# Production-Ready FrankenPHP Docker Images with Custom Caddy Builds

[![Docker Pulls](https://img.shields.io/docker/pulls/morsalin1342/frankenphp.svg?style=for-the-badge&logo=docker)](https://hub.docker.com/r/morsalin1342/frankenphp)
[![GitHub Stars](https://img.shields.io/github/stars/morsalin1342/frankenphp-docker?style=for-the-badge&logo=github)](https://github.com/morsalin1342/frankenphp-docker)
[![License](https://img.shields.io/github/license/morsalin1342/frankenphp-docker?style=for-the-badge)](https://github.com/morsalin1342/frankenphp-docker/blob/master/LICENSE)

This repository contains the build instructions for a set of customized, production-ready **FrankenPHP** Docker images. They are built on the official `dunglas/frankenphp` base and include a powerful, custom-compiled Caddy web server, a comprehensive set of pre-installed PHP extensions, and common utilities to support modern PHP applications including **Laravel**, **Symfony**, and **WordPress**.

The images are automatically built and published to [Docker Hub](https://hub.docker.com/r/morsalin1342/frankenphp) for multiple PHP versions via GitHub Actions.

## ✨ Why This Image?

| Feature | Official `dunglas/frankenphp` | This Image |
|---------|-------------------------------|------------|
| **Caddy modules** | Minimal | 15+ plugins (Brotli, Mercure, Souin cache, 6 DNS providers) |
| **PHP extensions** | Few built-in | 50+ pre-installed (Redis, MongoDB, Swoole, Imagick, etc.) |
| **Composer** | ❌ | ✅ Latest |
| **WP-CLI** | ❌ | ✅ Latest |
| **Node.js** | ❌ | ✅ v24 (configurable) |
| **Supervisor + Cron** | ❌ | ✅ |
| **Ready to deploy** | Needs setup | `docker compose up` and you're running |

## Quick Start

FrankenPHP is a self-contained application server, so you don't need a separate web server like Nginx. The easiest way to get started is with a `docker-compose.yml` file.

Here is an example serving a simple application:

```yaml
# docker-compose.yml
version: '3.8'

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
*   `morsalin1342/frankenphp:<version>-bookworm` (e.g., `morsalin1342/frankenphp:8.4-bookworm`): The full tag specifying the base OS.

It is recommended to use a specific version tag (like `8.4-bookworm`) in production environments for stability.

## Included Extensions & Utilities

These images come with a wide range of pre-installed components to minimize setup time.

### Custom Caddy Modules

The `frankenphp` binary is custom-compiled with the following additional Caddy modules:

*   **cbrotli**: Brotli compression support.
*   **mercure**: Server-sent events hub.
*   **vulcain**: Linked Data API gateway.
*   **souin**: HTTP Cache.
*   **DNS Challenge Providers**: `vultr`, `azure`, `googleclouddns`, `digitalocean`, `cloudflare`, `route53`.
*   **Souin Storage Providers**: `go-redis`, `otter`, `simplefs`.

### PHP Extensions

| Category         | Extensions                                                                    |
|------------------|-------------------------------------------------------------------------------|
| **Performance**  | `apcu`, `igbinary`, `memcached`, `opcache`, `redis`                             |
| **Asynchronous** | `amqp`, `openswoole`, `pcntl`, `rdkafka`, `sockets`                             |
| **Databases**    | `mongodb`, `mysqli`, `pdo_mysql`, `pdo_pgsql`                                   |
| **Utilities**    | `bcmath`, `brotli`, `bz2`, `calendar`, `csv`, `ds`, `enchant`, `exif`, `ffi`, `gd`, `gettext`, `gmp`, `gnupg`, `grpc`, `http`, `imagick`, `inotify`, `intl`, `ldap`, `mailparse`, `mcrypt`, `oauth`, `protobuf`, `pspell`, `shmop`, `soap`, `ssh2`, `tidy`, `timezonedb`, `uuid`, `xmlrpc`, `xsl`, `yaml`, `zip`, `zstd` |
| **Development**  | `pcov` (for code coverage)                                                    |

### Command-Line Utilities

*   **Composer**: The standard PHP dependency manager.
*   **WP-CLI**: The official command-line tool for WordPress.
*   **Node.js**: v24.x, for frontend asset compilation and other tasks.
*   **Supervisor**: A process control system for managing long-running scripts.
*   **Cron**: For scheduling recurring tasks.
*   **Other Tools**: `curl`, `gosu`, `unzip`, `zip`, `ffmpeg`.

## Configuration

*   The images are pre-configured with a hardened `php.ini` for production security and performance. This includes `open_basedir` restrictions, disabled dangerous functions, and optimized memory/size limits.
*   The server is configured by mounting a custom `Caddyfile` to `/etc/caddy/Caddyfile` inside the container.

## ❓ FAQ

**Q: Can I run custom php.ini configurations?**
A: Absolutely. You can mount your own `php.ini` file into the container:
```yaml
    volumes:
      - ./php.ini:/usr/local/etc/php/php.ini:ro
```

**Q: How do I add extensions not in your list?**
A: Since we use the `mlocati/php-extension-installer` utility, you can easily install any other extension via a custom `Dockerfile` layer:
```dockerfile
FROM morsalin1342/frankenphp:8.4
RUN install-php-extensions my-custom-extension
```

**Q: Why Node.js v24?**
A: We prioritize stability and long-term support. Node.js 24 is excellent for modern build tooling like Vite, Webpack, or TailwindCSS. You can customize the Node.js version at build time with the `NODE_VERSION` build arg.

**Q: How do I manage queues or background processes?**
A: The images include `supervisor`. You can mount your configuration in `/etc/supervisor/conf.d/` to manage worker processes.

**Q: How do I configure HTTPS with a custom domain?**
A: FrankenPHP's built-in Caddy server obtains TLS certificates automatically via Let's Encrypt. Specify your domain in the `Caddyfile` and ensure ports 80 and 443 are exposed.

---

## Feedback and Issues

If you have suggestions, find a bug, or want to request a new extension, please [open an issue](https://github.com/morsalin1342/frankenphp-docker/issues) on the GitHub repository.

---

⭐ **If this project helps you, consider giving it a star!**
