# FrankenPHP — Production-Ready PHP App Server with Custom Caddy Builds

**Maintained by [morsalin1342](https://hub.docker.com/u/morsalin1342)** · [GitHub](https://github.com/morsalin1342/frankenphp-docker)

FrankenPHP is a modern PHP app server built in Go. This image bundles a custom-compiled Caddy web server, 50+ PHP extensions, and essential CLI tools — everything you need to run production PHP applications in a single container.

## Quick Start

```yaml
# docker-compose.yml
services:
  app:
    image: morsalin1342/frankenphp:8.4
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./public:/app
      - ./Caddyfile:/etc/caddy/Caddyfile
```

```caddy
# Caddyfile
:80 {
    root * /app
    encode zstd gzip
    php_server
    file_server
}
```

## Available Tags

| Tag | PHP | Base OS |
|-----|-----|---------|
| `latest`, `8.5`, `8.5-bookworm` | 8.5 | bookworm |
| `8.4`, `8.4-bookworm` | 8.4 | bookworm |
| `8.3`, `8.3-bookworm` | 8.3 | bookworm |
| `8.2`, `8.2-bookworm` | 8.2 | bookworm |
| `8.5-trixie` … `8.2-trixie` | 8.2–8.5 | trixie |

`bookworm` owns the unsuffixed tags; append `-trixie` for Debian 13.

## What's Included

- **Custom Caddy** with the OWASP Coraza WAF (CRS compiled in), rate limiting,
  AI-crawler blocking, Brotli, HTTP cache (Souin), and 6 DNS challenge providers
- **50+ PHP extensions**: Redis, MongoDB, PostgreSQL, Imagick, GD, Intl, AMQP, Kafka, OpenTelemetry, and more
- **Tools**: Composer, WP-CLI, Node.js 24, Supervisor, Cron, FFmpeg

## Customizing

```dockerfile
FROM morsalin1342/frankenphp:8.4
RUN install-php-extensions xdebug
COPY php.ini /usr/local/etc/php/php.ini
```

---

### 🔗 Related Images & Tools

| Image / Tool | Description |
|--------------|-------------|
| [morsalin1342/caddy](https://hub.docker.com/r/morsalin1342/caddy) | Standalone Caddy with WAF, rate limiting & caching |
| [morsalin1342/php](https://hub.docker.com/r/morsalin1342/php) | Traditional PHP-FPM & CLI images |
| [morsalin1342/nginx](https://hub.docker.com/r/morsalin1342/nginx) | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 |
| [easydigital/frankenphp](https://hub.docker.com/r/easydigital/frankenphp) | Enterprise org mirror |
| [caddy-souin-cache-manager](https://github.com/morsalin1342/caddy-souin-cache-manager) | Manage this image's Souin cache from WP Admin |
