# FrankenPHP — Production-Ready PHP App Server with Custom Caddy Builds

**Maintained by [morsalin1342](https://hub.docker.com/u/morsalin1342)** · [GitHub](https://github.com/morsalin1342/frankenphp-docker)

[![Docker Pulls](https://img.shields.io/docker/pulls/morsalin1342/frankenphp?style=for-the-badge&logo=docker)](https://hub.docker.com/r/morsalin1342/frankenphp)
[![Image Size](https://img.shields.io/docker/image-size/morsalin1342/frankenphp/latest?style=for-the-badge&logo=docker)](https://hub.docker.com/r/morsalin1342/frankenphp/tags)
[![GitHub Stars](https://img.shields.io/github/stars/morsalin1342/frankenphp-docker?style=for-the-badge&logo=github)](https://github.com/morsalin1342/frankenphp-docker)
[![License](https://img.shields.io/github/license/morsalin1342/frankenphp-docker?style=for-the-badge)](https://github.com/morsalin1342/frankenphp-docker/blob/master/LICENSE)

FrankenPHP is a modern PHP app server built in Go. This image bundles a custom-compiled Caddy web server, 56 PHP extensions, and essential CLI tools — everything you need to run production PHP applications in a single container.

## ✨ Why This Image?

| Feature | Official image | This image |
|---|---|---|
| **Caddy modules** | Minimal | ✅ 16 — WAF, rate limiting, Brotli, Souin, 6 DNS |
| **Web application firewall** | ❌ | ✅ OWASP Coraza, Core Rule Set compiled in |
| **PHP extensions** | Few built in | ✅ 56 pre-installed |
| **Composer / WP-CLI** | ❌ | ✅ Both |
| **Node.js** | ❌ | ✅ v24, configurable |
| **Supervisor + Cron** | ❌ | ✅ |
| **Debian releases** | One | ✅ bookworm and trixie |

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
- **56 PHP extensions**: Redis, MongoDB, PostgreSQL, Imagick, GD, Intl, AMQP, Kafka, OpenTelemetry, and more
- **Tools**: Composer, WP-CLI, Node.js 24, Supervisor, Cron, FFmpeg

## Customizing

```dockerfile
FROM morsalin1342/frankenphp:8.4
RUN install-php-extensions xdebug
COPY php.ini /usr/local/etc/php/php.ini
```

## ❓ FAQ

**Q: Can I add extensions?**
A: Yes — `RUN install-php-extensions <name>` in a layer on top; the installer is already in the image.

**Q: How do I run queue workers?**
A: Supervisor is installed. Mount your config into `/etc/supervisor/conf.d/`.

**Q: bookworm or trixie?**
A: Unsuffixed tags are bookworm. Append `-trixie` for Debian 13.

---

### 🔗 Related Images & Tools

| Image / Tool | Description |
|--------------|-------------|
| [morsalin1342/caddy](https://hub.docker.com/r/morsalin1342/caddy) | Standalone Caddy with WAF, rate limiting & caching |
| [morsalin1342/php](https://hub.docker.com/r/morsalin1342/php) | Traditional PHP-FPM & CLI images |
| [morsalin1342/nginx](https://hub.docker.com/r/morsalin1342/nginx) | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 |
| [easydigital/frankenphp](https://hub.docker.com/r/easydigital/frankenphp) | Enterprise org mirror |
| [caddy-souin-cache-manager](https://github.com/morsalin1342/caddy-souin-cache-manager) | Manage this image's Souin cache from WP Admin |

---

⭐ **If this image helps you, consider giving it a star on [GitHub](https://github.com/morsalin1342/frankenphp-docker)!**
