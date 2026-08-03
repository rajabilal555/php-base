# Legacy Caddy + PHP-FPM + Supervisor stack.
# Published under the *-fpm tags for apps that have not migrated yet.
ARG PHP_VERSION=8.4
FROM docker.io/library/php:${PHP_VERSION}-fpm-alpine AS php-base

ENV APP_USER=app \
    APP_UID=1000 \
    APP_GID=1000

# Install system dependencies
RUN apk add --no-cache dcron busybox-suid libcap curl zip unzip git npm ffmpeg tzdata

# Install PHP extensions
COPY --from=docker.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions intl bcmath gd pdo_mysql pdo_pgsql opcache redis uuid exif pcntl zip

# Install supervisord implementation
COPY --from=docker.io/ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

# Install caddy
COPY --from=docker.io/library/caddy:2.7 /usr/bin/caddy /usr/local/bin/caddy
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

# Install composer
COPY --from=docker.io/composer/composer:2 /usr/bin/composer /usr/local/bin/composer

RUN addgroup -g ${APP_GID} -S ${APP_USER} && adduser -D -u ${APP_UID} -G ${APP_USER} -S ${APP_USER}
RUN addgroup ${APP_USER} wheel

# Common PHP config
COPY ./config/php/local.ini /usr/local/etc/php/conf.d/local.ini

WORKDIR /app
