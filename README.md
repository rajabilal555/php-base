# php-base

Minimal base image for PHP applications, packaged as a Docker image.

Usage
-----

Build locally (override PHP version if needed):

```bash
docker build -f php-base.Dockerfile --build-arg PHP_VERSION=8.4 -t php-base:php-8.4 .
```

Pull the published image from GitHub Container Registry:

```bash
docker pull ghcr.io/<OWNER>/php-base:php-8.4
```

Replace <OWNER> with your GitHub organization or user name.

Publishing
----------

The repository includes a GitHub Actions workflow at `.github/workflows/publish.yml` that builds and publishes images to `ghcr.io` when you push tags like `v*` or `php-*` or via a manual workflow dispatch.

Docker Hub publishing
---------------------

If you prefer Docker Hub, the workflow can also publish to Docker Hub. Set the following secrets in the repository settings:

- `DOCKERHUB_USERNAME` — your Docker Hub username.
- `DOCKERHUB_TOKEN` — a Docker Hub access token or password.

When the secrets are present, the same workflow will push images to `docker.io/<DOCKERHUB_USERNAME>/php-base:php-<version>` and `docker.io/<DOCKERHUB_USERNAME>/php-base:latest`.

To manually build and push to Docker Hub locally:

```bash
docker build --build-arg PHP_VERSION=8.4 -t ${DOCKERHUB_USERNAME}/php-base:php-8.4 .
docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_TOKEN}
docker push ${DOCKERHUB_USERNAME}/php-base:php-8.4
```

