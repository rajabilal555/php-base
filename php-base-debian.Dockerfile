ARG PHP_VERSION=8.4
FROM docker.io/dunglas/frankenphp:1-php${PHP_VERSION}-bookworm
ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl zip unzip git npm ffmpeg tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions intl bcmath gd pdo_mysql pdo_pgsql opcache redis uuid exif pcntl zip

COPY --from=docker.io/ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
RUN curl -fsSL -o /usr/local/bin/supercronic \
        "https://github.com/aptible/supercronic/releases/download/v0.2.44/supercronic-linux-${TARGETARCH}" \
    && chmod +x /usr/local/bin/supercronic

COPY --from=docker.io/composer/composer:2 /usr/bin/composer /usr/local/bin/composer

ARG NON_ROOT_UID=1000
ARG NON_ROOT_GID=1000
ARG NON_ROOT_GROUP=app
ARG NON_ROOT_USER=app
RUN groupadd -g ${NON_ROOT_GID} ${NON_ROOT_GROUP} \
    && useradd -m -u ${NON_ROOT_UID} -g ${NON_ROOT_GROUP} -s /bin/bash ${NON_ROOT_USER} \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && chown -R ${NON_ROOT_USER}:${NON_ROOT_GROUP} /config/caddy /data/caddy

COPY ./config/php/local.ini /usr/local/etc/php/conf.d/local.ini

WORKDIR /app

USER ${NON_ROOT_USER}

EXPOSE 80
