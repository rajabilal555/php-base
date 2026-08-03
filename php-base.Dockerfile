ARG PHP_VERSION=8.4
FROM docker.io/dunglas/frankenphp:1-php${PHP_VERSION}-alpine
ARG TARGETARCH

RUN apk add --no-cache curl zip unzip git npm ffmpeg tzdata

RUN install-php-extensions intl bcmath gd pdo_mysql pdo_pgsql opcache redis uuid exif pcntl zip

COPY --from=docker.io/ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
RUN curl -fsSL -o /usr/local/bin/supercronic \
        "https://github.com/aptible/supercronic/releases/download/v0.2.44/supercronic-linux-${TARGETARCH}" \
    && chmod +x /usr/local/bin/supercronic

COPY --from=docker.io/composer/composer:2 /usr/bin/composer /usr/local/bin/composer

RUN addgroup -g 1000 -S app \
    && adduser -D -u 1000 -G app -s /bin/sh app \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && chown -R app:app /config/caddy /data/caddy

COPY ./config/php/local.ini /usr/local/etc/php/conf.d/local.ini

WORKDIR /app

USER app

EXPOSE 80
