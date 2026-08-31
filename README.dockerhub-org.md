# FrankenPHP — Enterprise PHP App Server

**Published by [easydigital](https://hub.docker.com/u/easydigital)** · [GitHub](https://github.com/morsalin1342/frankenphp-docker)

Enterprise-ready FrankenPHP images with a custom Caddy build, 50+ PHP extensions, and production tooling. Same image as `morsalin1342/frankenphp` — published here for organizational use.

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

## Tags

`8.5`, `8.5-bookworm`, `8.5-trixie`, `8.4`, `8.4-bookworm`, `8.4-trixie`, `8.3`, `8.3-bookworm`, `8.3-trixie`, `8.2`, `8.2-bookworm`, `8.2-trixie`, `latest` → 8.5

Unsuffixed tags are bookworm; append `-trixie` for Debian 13.

---

### 🔗 Related Images & Tools

| Image / Tool | Description |
|--------------|-------------|
| [easydigital/caddy](https://hub.docker.com/r/easydigital/caddy) | Standalone Caddy with WAF, rate limiting & caching (org) |
| [easydigital/php](https://hub.docker.com/r/easydigital/php) | Traditional PHP-FPM & CLI images (org) |
| [easydigital/nginx](https://hub.docker.com/r/easydigital/nginx) | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 (org) |
| [morsalin1342/frankenphp](https://hub.docker.com/r/morsalin1342/frankenphp) | Personal account mirror |
| [caddy-souin-cache-manager](https://github.com/morsalin1342/caddy-souin-cache-manager) | Manage this image's Souin cache from WP Admin |
