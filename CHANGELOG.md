# CHANGELOG

All notable changes to this project will be documented in this file.

## [php-8.4-frankenphp] - 2026-07-26

- **Breaking:** Default image is now based on [FrankenPHP](https://frankenphp.dev/) instead of PHP-FPM + Caddy + Supervisor.
- FrankenPHP tags: `php-8.4`, `latest`.
- Legacy FPM stack remains available as `php-8.4-fpm` (built from `php-base-fpm.Dockerfile` on tag releases).
- GHCR publish workflow updated: consistent `php-<version>` tags, optional FPM variant, Docker Hub only when secrets are set.

## [php-8.4] - 2025-12-01

- Bumped default PHP version from `8.3` to `8.4` in `php-base.Dockerfile`.
