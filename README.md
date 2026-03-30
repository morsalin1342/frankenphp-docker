# Production-Ready FrankenPHP Docker Images with Custom Caddy Builds

[![Docker Pulls](https://img.shields.io/docker/pulls/morsalin1342/frankenphp.svg)](https://hub.docker.com/r/morsalin1342/frankenphp)

This repository contains the build instructions for a set of customized, production-ready **FrankenPHP** Docker images. They are built on the official `dunglas/frankenphp` base and include a powerful, custom-compiled Caddy web server, a comprehensive set of pre-installed PHP extensions, and common utilities to support modern PHP applications.

The images are automatically built and published to [Docker Hub](https://hub.docker.com/r/morsalin1342/frankenphp) for multiple PHP versions via GitHub Actions.

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

*   The images are configured using the `php.ini-production` template for better security and performance.
*   The server is configured by mounting a custom `Caddyfile` to `/etc/caddy/Caddyfile` inside the container.

## Feedback and Issues

If you have suggestions, find a bug, or want to request a new extension, please [open an issue](https://github.com/morsalin1342/frankenphp-docker/issues) on the GitHub repository.
