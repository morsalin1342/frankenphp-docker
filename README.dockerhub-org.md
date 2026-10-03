# FrankenPHP — Enterprise PHP App Server

**Published by [easydigital](https://hub.docker.com/u/easydigital)** · [GitHub](https://github.com/morsalin1342/frankenphp-docker)

[![Docker Pulls](https://img.shields.io/docker/pulls/easydigital/frankenphp?style=for-the-badge&logo=docker)](https://hub.docker.com/r/easydigital/frankenphp)
[![Image Size](https://img.shields.io/docker/image-size/easydigital/frankenphp/latest?style=for-the-badge&logo=docker)](https://hub.docker.com/r/easydigital/frankenphp/tags)
[![GitHub Stars](https://img.shields.io/github/stars/morsalin1342/frankenphp-docker?style=for-the-badge&logo=github)](https://github.com/morsalin1342/frankenphp-docker)
[![License](https://img.shields.io/github/license/morsalin1342/frankenphp-docker?style=for-the-badge)](https://github.com/morsalin1342/frankenphp-docker/blob/master/LICENSE)

Enterprise-ready FrankenPHP images with a custom Caddy build, 56 PHP extensions, and production tooling. Same image as `morsalin1342/frankenphp` — published here for organizational use.

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

## Why Use the easydigital Registry?

- **Namespace isolation** — keep team pulls under the organization account
- **Same image digest** — bit-for-bit identical to `morsalin1342/frankenphp`
- **CI/CD friendly** — predictable tags for automated pipelines

## Deployment Example

```yaml
# production.yml
services:
  app:
    image: easydigital/frankenphp:8.4-bookworm
    restart: always
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./public:/app
      - ./Caddyfile:/etc/caddy/Caddyfile
      - app_data:/data
    environment:
      SERVER_NAME: example.com

volumes:
  app_data:
```

## Caddyfile with HTTPS

```caddy
example.com {
    root * /app/public
    encode zstd gzip
    php_server
    file_server
    header Strict-Transport-Security "max-age=63072000"
}
```

## Available Tags

`8.5`, `8.5-bookworm`, `8.5-trixie`, `8.4`, `8.4-bookworm`, `8.4-trixie`, `8.3`, `8.3-bookworm`, `8.3-trixie`, `8.2`, `8.2-bookworm`, `8.2-trixie`, `latest` → 8.5

Unsuffixed tags are bookworm; append `-trixie` for Debian 13.

## ❓ FAQ

**Q: Can I add extensions?**
A: Yes — `RUN install-php-extensions <name>` in a layer on top; the installer is already in the image.

**Q: How do I run queue workers?**
A: Supervisor is installed. Mount your config into `/etc/supervisor/conf.d/`.

**Q: bookworm or trixie?**
A: Unsuffixed tags are bookworm. Append `-trixie` for Debian 13.

---

### 🔗 Related Images & Tools

<!-- BEGIN GENERATED: related (from images.yaml in the org .github repository; do not edit by hand) -->
| Image / Tool | Description |
|--------------|-------------|
| [easydigital/caddy](https://hub.docker.com/r/easydigital/caddy) | Standalone Caddy with WAF, rate limiting & caching |
| [easydigital/php](https://hub.docker.com/r/easydigital/php) | Traditional PHP-FPM & CLI images |
| [easydigital/nginx](https://hub.docker.com/r/easydigital/nginx) | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 |
| [easydigital/apache](https://hub.docker.com/r/easydigital/apache) | Apache as a static server or php-fpm application server, no PHP inside |
| [morsalin1342/frankenphp](https://hub.docker.com/r/morsalin1342/frankenphp) | Same image, personal namespace |
<!-- END GENERATED: related -->

---

⭐ **If this image helps you, consider giving it a star on [GitHub](https://github.com/morsalin1342/frankenphp-docker)!**
