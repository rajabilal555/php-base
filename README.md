# php-base

Minimal base image for PHP applications, packaged as a Docker image.

Usage
-----

Build locally (override PHP version if needed):

```bash
docker build --build-arg PHP_VERSION=8.4 -t php-base:php-8.4 .
```

Pull the published image from GitHub Container Registry:

```bash
docker pull ghcr.io/<OWNER>/php-base:php-8.4
```

Replace <OWNER> with your GitHub organization or user name.

Publishing
----------

The repository includes a GitHub Actions workflow at `.github/workflows/publish.yml` that builds and publishes images to `ghcr.io` when you push tags like `v*` or `php-*` or via a manual workflow dispatch.
