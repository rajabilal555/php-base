ARG PHP_VERSION=8.4
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine

# Runtime utilities used by downstream application images
RUN apk add --no-cache dcron busybox-suid curl zip unzip git npm ffmpeg

# PHP extensions
RUN install-php-extensions intl bcmath gd pdo_mysql pdo_pgsql opcache redis uuid exif pcntl zip

# Composer
COPY --from=composer/composer:2 /usr/bin/composer /usr/local/bin/composer

# Non-root user
ARG NON_ROOT_GROUP=app
ARG NON_ROOT_USER=app
RUN addgroup -S ${NON_ROOT_GROUP} \
    && adduser -S ${NON_ROOT_USER} -G ${NON_ROOT_GROUP} \
    && addgroup ${NON_ROOT_USER} wheel \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && chown -R ${NON_ROOT_USER}:${NON_ROOT_GROUP} /config/caddy /data/caddy

# Common PHP config
COPY ./config/php/local.ini /usr/local/etc/php/conf.d/local.ini

WORKDIR /app

USER ${NON_ROOT_USER}

EXPOSE 80 443 443/udp
