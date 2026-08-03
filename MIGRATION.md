# Migrating to FrankenPHP

Guide for Laravel apps currently on the old **PHP-FPM + Caddy + crond** base image.

Reference: [rajabilal555/php-base](https://github.com/rajabilal555/php-base) — see `example/` for the target setup.

## Not ready yet?

Pin the legacy base image in your app `Dockerfile`:

```dockerfile
FROM ghcr.io/rajabilal555/php-base:php-8.4-fpm
```

No other changes needed. Rebuild and redeploy in Dokploy as usual.

> `php-8.4-fpm` is published on version tag releases (`php-8.4`, etc.), not on every `main` build.

---

## Ready to migrate

### What changes

| Before (FPM) | After (FrankenPHP) |
| --- | --- |
| `php-fpm` + `caddy` (2 processes) | `frankenphp` (1 process) |
| `crond` + crontab file | `supercronic` + crontab file |
| `php_fastcgi 127.0.0.1:9000` in Caddyfile | `php_server` in Caddyfile |
| crond setcap/chmod hacks in Dockerfile | removed |

Queue worker via supervisor stays the same idea.

### Steps

**1. Update base image tag**

```dockerfile
FROM ghcr.io/rajabilal555/php-base:php-8.4
```

Change the `php-8.4` tag when you upgrade PHP. No build-args needed.

**2. Replace `.deploy/config/supervisor.conf`**

One file, three active programs: `frankenphp`, `supercronic`, `laravel-queue`.

Copy from [example/.deploy/config/supervisor.conf](https://github.com/rajabilal555/php-base/blob/main/example/.deploy/config/supervisor.conf).

Remove old `[program:php-fpm]`, `[program:caddy]`, and `[program:cron]` blocks.

**3. Replace `.deploy/config/Caddyfile`**

Copy from [example/.deploy/config/Caddyfile](https://github.com/rajabilal555/php-base/blob/main/example/.deploy/config/Caddyfile).

Keep your custom blocks (websockets, redirects, etc.) — swap `php_fastcgi` for `php_server`.

**4. Simplify crontab**

In `.deploy/config/crontab`:

```cron
* * * * * php artisan schedule:run
```

Remove the old `/etc/crontabs/` copy and crond `chmod`/`setcap` lines from your Dockerfile.

**5. Update entrypoint**

Copy from [example/.deploy/entrypoint.sh](https://github.com/rajabilal555/php-base/blob/main/example/.deploy/entrypoint.sh).

Key addition: `export SERVER_ROOT="${LARAVEL_PATH}/public"` before starting supervisord.

**6. Add env vars to Dockerfile (or Dokploy)**

```dockerfile
ENV LARAVEL_PATH=/srv/app
ENV SERVER_NAME=:80
```

`SERVER_NAME=:80` serves HTTP only inside the container. Dokploy's reverse proxy handles TLS in front — same pattern as before.

Set `USER ${APP_USER}` in your app Dockerfile before `composer` / `npm` and for runtime (see `example/Dockerfile`). Prefer `COPY --chown=${APP_USER}:${APP_USER}` over `COPY` + `RUN chown`.

**7. Rebuild and deploy**

Push to git → Dokploy rebuilds the image → redeploy.

---

## Dokploy notes

- **Port:** expose `80` on the container (unchanged).
- **HTTPS:** terminate at Dokploy's proxy; keep `SERVER_NAME=:80` in the container.
- **Volumes:** app user is `app` (UID 1000, exposed as `APP_USER` / `APP_UID` / `APP_GID` in the image). Existing volume mounts should keep working; if you hit permission errors, `chown` mounted dirs to `1000:1000`.
- **Healthcheck:** optional — see [example/Dockerfile](https://github.com/rajabilal555/php-base/blob/main/example/Dockerfile).

---

## Checklist

- [ ] `FROM` points to `php-8.4` (not `latest` if you want a pinned version)
- [ ] `supervisor.conf` — frankenphp + supercronic + queue (no php-fpm/caddy/cron)
- [ ] `Caddyfile` — `php_server`, env-based `SERVER_NAME` / `SERVER_ROOT`
- [ ] Dockerfile — no crond lines
- [ ] `entrypoint.sh` sets `SERVER_ROOT`
- [ ] App loads, queue processes jobs, scheduler runs

## Rollback

Change `FROM` back to `php-8.4-fpm` and redeploy. Your old `.deploy/` files should still be in git history.
