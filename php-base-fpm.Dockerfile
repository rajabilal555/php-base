# Legacy Caddy + PHP-FPM + Supervisor stack.
# Published under the *-fpm tags for apps that have not migrated yet.
ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm-alpine AS php-base

RUN apk add --no-cache dcron busybox-suid libcap curl zip unzip git npm ffmpeg

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions intl bcmath gd pdo_mysql pdo_pgsql opcache redis uuid exif pcntl zip

COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

COPY --from=caddy:2.7 /usr/bin/caddy /usr/local/bin/caddy
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

COPY --from=composer/composer:2 /usr/bin/composer /usr/local/bin/composer

ARG NON_ROOT_GROUP=app
ARG NON_ROOT_USER=app
RUN addgroup -S ${NON_ROOT_GROUP} && adduser -S ${NON_ROOT_USER} -G ${NON_ROOT_GROUP}
RUN addgroup ${NON_ROOT_USER} wheel

COPY ./config/php/local.ini /usr/local/etc/php/conf.d/local.ini

WORKDIR /app
