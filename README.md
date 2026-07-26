# php-base

Minimal base image for PHP applications, built on [FrankenPHP](https://frankenphp.dev/) (Caddy + PHP in a single optimized process).

## Usage

Build locally:

```bash
docker build -f php-base.Dockerfile --build-arg PHP_VERSION=8.4 -t php-base:php-8.4 .
```

Pull the published image from GitHub Container Registry:

```bash
docker pull ghcr.io/rajabilal555/php-base:php-8.4
# or
docker pull ghcr.io/rajabilal555/php-base:latest
```

FrankenPHP serves HTTP on ports 80 and 443 by default. Mount your app and run:

```bash
docker run --rm -p 8080:80 -v "$PWD:/app/public" ghcr.io/rajabilal555/php-base:latest
```

Set `SERVER_NAME` (for example `:8000`) if you want a non-privileged port inside the container.

## Image variants

| Tag | Stack | Notes |
| --- | --- | --- |
| `php-8.4`, `latest` | **FrankenPHP** (default) | Lower memory use; Caddy and PHP in one process |
| `php-8.4-fpm` | PHP-FPM + Caddy + Supervisor | Legacy stack for apps not yet migrated |

**Recommendation:** use `latest` / `php-8.4` for new work. Pin `php-8.4-fpm` only if you still rely on the old FPM + Supervisor layout.

## Publishing to GHCR

Images are published to `ghcr.io/<OWNER>/php-base` by GitHub Actions (`.github/workflows/publish.yml`).

Triggers:

- Push to `main`
- Version tags: `v*` or `php-*` (for example `php-8.4`)
- Manual **workflow dispatch** from the Actions tab

On tag releases, both FrankenPHP (`latest`, `php-<version>`) and legacy FPM (`php-<version>-fpm`) images are built. Manual runs publish FrankenPHP by default; enable **Also publish the legacy PHP-FPM + Caddy image** to include the FPM variant.

### First-time GHCR setup

1. Push this repo to GitHub (or merge the PR).
2. Run the workflow manually (**Actions → Build and publish Docker image → Run workflow**), or push a tag:

   ```bash
   git tag php-8.4
   git push origin php-8.4
   ```

3. In GitHub: **Packages** → `php-base` → **Package settings** → set visibility (public if you want open pulls).

The workflow uses `GITHUB_TOKEN` for `ghcr.io`; no extra secrets are required for GHCR.

## Docker Hub (optional)

Set these repository secrets to also push to Docker Hub:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

Images are published as `docker.io/<DOCKERHUB_USERNAME>/php-base:php-<version>` and `:latest`.

## Migrating from the FPM image

The default image no longer includes Supervisor, standalone Caddy, or `php-fpm`. Downstream Dockerfiles should:

1. Use FrankenPHP as the process manager (remove Supervisor/Caddy/FPM wiring).
2. Put the web root at `/app/public` (FrankenPHP default) or set `SERVER_ROOT`.
3. Expose ports `80`, `443`, and `443/udp` instead of a separate FPM socket.

If you need the previous stack temporarily, use `ghcr.io/<OWNER>/php-base:php-8.4-fpm`.
