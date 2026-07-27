# php-base

[![Build](https://github.com/rajabilal555/php-base/actions/workflows/publish.yml/badge.svg)](https://github.com/rajabilal555/php-base/actions/workflows/publish.yml)
[![Docker Hub](https://img.shields.io/docker/v/rajabilal555/php-base?sort=semver&logo=docker&label=Docker%20Hub)](https://hub.docker.com/r/rajabilal555/php-base)
[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io-181717?logo=github)](https://github.com/rajabilal555/php-base/pkgs/container/php-base)
[![FrankenPHP](https://img.shields.io/badge/FrankenPHP-powered-00ADD8)](https://frankenphp.dev/)
[![Platforms](https://img.shields.io/badge/platform-amd64%20%7C%20arm64-lightgrey)](https://github.com/rajabilal555/php-base)

FrankenPHP base image with Composer, common PHP extensions, and `supervisord` + `supercronic` for single-container Laravel apps. See `example/` for a full downstream setup.

Runs as user `app` (UID/GID **1000**).

## Usage

```bash
docker build -f php-base.Dockerfile --build-arg PHP_VERSION=8.4 -t php-base:php-8.4 .

# GHCR
docker pull ghcr.io/rajabilal555/php-base:php-8.4

# Docker Hub
docker pull docker.io/rajabilal555/php-base:php-8.4
```

Podman works the same (`podman build ...`). Image names use full `docker.io/...` paths so Podman doesn't need short-name alias config.

Set `SERVER_NAME` (for example `:8000` or your domain) and `SERVER_ROOT` if needed. Default FrankenPHP image uses `/etc/frankenphp/Caddyfile` with the same env vars.

```bash
docker run --rm -p 8080:80 -e SERVER_NAME=:80 -v "$PWD:/app" -w /app ghcr.io/rajabilal555/php-base:latest
```

## Example app

Copy `example/` into your Laravel repo as `.deploy/` and adapt the Dockerfile. One supervisor config runs everything:

```
supervisord
├── frankenphp   → HTTP
├── supercronic  → schedule:run
└── queue:work   → queue worker
```

FrankenPHP env vars (see [official Caddyfile](https://github.com/php/frankenphp/blob/main/caddy/frankenphp/Caddyfile)):

| Env | Default in example | Purpose |
| --- | --- | --- |
| `SERVER_NAME` | `:80` | Listen address (`:80` = HTTP only, no auto-TLS) |
| `LARAVEL_PATH` | `/srv/app` | Project root (artisan, app code) |
| `SERVER_ROOT` | `$LARAVEL_PATH/public` | Web root — set in entrypoint, do not point at project root |
| `CADDY_GLOBAL_OPTIONS` | — | Global Caddy options (e.g. `debug`) |
| `FRANKENPHP_CONFIG` | — | Extra `frankenphp {}` config |
| `CADDY_SERVER_EXTRA_DIRECTIVES` | — | Inject directives into the site block |

## Tags

| Tag | Stack | Notes |
| --- | --- | --- |
| `php-8.4` | FrankenPHP | **Pin this in production** |
| `latest` | FrankenPHP | Same as `php-8.4` (only updated when building the default PHP version) |
| `php-8.4-fpm` | Legacy PHP-FPM + Caddy | Tag releases only |

When the default PHP version moves to 8.5, bump `DEFAULT_PHP_VERSION` in the workflow — `latest` will follow.

See [MIGRATION.md](MIGRATION.md) for upgrading existing deployments.

## Publishing

Images publish to GHCR and Docker Hub on push to `main`, version tags (`php-*`, `v*`), or manual workflow dispatch. See `.github/workflows/publish.yml`.
