# CHANGELOG

All notable changes to this project will be documented in this file.

## [Unreleased]

- Publish FrankenPHP Debian (bookworm) image as `php-<version>-debian` on every `main` push (alongside Alpine).
- FrankenPHP base: chown `/config` and `/data` to `app` so PsySH/Tinker can write under `XDG_CONFIG_HOME` (`/config/psysh`); set `HOME=/home/app`.
- Legacy FPM base image: `app` user fixed to UID/GID 1000 (matches FrankenPHP base) for stable volume permissions.
- Base image build no longer ends with `USER app` — downstream Dockerfiles can chown without `USER root`; set `USER ${APP_USER}` in app images for runtime.
- Removed `EXPOSE 80` from base images (FrankenPHP parent already documents port 80; app Dockerfile keeps it).
- Simplified Docker config: `APP_USER` / `APP_UID` / `APP_GID` as image env vars (not build-args).
- Single PHP version source for CI (`DEFAULT_PHP_VERSION` in workflow); example app uses pinned image tag only.
- README "Where to edit" table for PHP version and user config.

## [php-8.4] - 2026-07-27

- Added `supervisord` and `supercronic` to the FrankenPHP base image.
- Removed `dcron` and `busybox-suid`; use Supercronic instead.
- Fixed `app` user to UID/GID 1000 for stable volume permissions across PHP upgrades.
- Expanded `config/php/local.ini` with OPcache, security, session, and realpath cache settings.
- Updated `example/` for FrankenPHP with a single `supervisor.conf`.
- `latest` tag only published when building the default PHP version; added GHA build cache.
- Added [MIGRATION.md](MIGRATION.md) for upgrading from the FPM stack.
- Full `docker.io/...` image paths for Podman compatibility; README badges.

## [php-8.4-frankenphp] - 2026-07-26

- **Breaking:** Default image is now based on [FrankenPHP](https://frankenphp.dev/) instead of PHP-FPM + Caddy + Supervisor.
- FrankenPHP tags: `php-8.4`, `latest`.
- Legacy FPM stack remains available as `php-8.4-fpm` (built from `php-base-fpm.Dockerfile` on tag releases).
- GHCR publish workflow updated: consistent `php-<version>` tags, optional FPM variant, publishes to GHCR and Docker Hub on every run.

## [php-8.4] - 2025-12-01

- Bumped default PHP version from `8.3` to `8.4` in `php-base.Dockerfile`.
