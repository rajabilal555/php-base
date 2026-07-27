# php-base

FrankenPHP base image with Composer, common PHP extensions, and `supervisord` + `supercronic` for single-container Laravel apps. See `example/` for a full downstream setup.

Runs as user `app` (UID/GID **1000**).

## Usage

```bash
docker build -f php-base.Dockerfile --build-arg PHP_VERSION=8.4 -t php-base:php-8.4 .
docker pull ghcr.io/rajabilal555/php-base:latest
```

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

| Tag | Stack |
| --- | --- |
| `php-8.4`, `latest` | FrankenPHP (default) |
| `php-8.4-fpm` | Legacy PHP-FPM + Caddy |

See [MIGRATION.md](MIGRATION.md) for upgrading existing deployments.

## Publishing

Images publish to GHCR and Docker Hub on push to `main`, version tags (`php-*`, `v*`), or manual workflow dispatch. See `.github/workflows/publish.yml`.
