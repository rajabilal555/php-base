ARG PHP_VERSION=8.4
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine
ARG TARGETARCH

RUN apk add --no-cache curl zip unzip git npm ffmpeg tzdata

RUN install-php-extensions intl bcmath gd pdo_mysql pdo_pgsql opcache redis uuid exif pcntl zip

COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
RUN curl -fsSL -o /usr/local/bin/supercronic \
        "https://github.com/aptible/supercronic/releases/download/v0.2.44/supercronic-linux-${TARGETARCH}" \
    && chmod +x /usr/local/bin/supercronic

COPY --from=composer/composer:2 /usr/bin/composer /usr/local/bin/composer

ARG NON_ROOT_UID=1000
ARG NON_ROOT_GID=1000
ARG NON_ROOT_GROUP=app
ARG NON_ROOT_USER=app
RUN addgroup -g ${NON_ROOT_GID} -S ${NON_ROOT_GROUP} \
    && adduser -D -u ${NON_ROOT_UID} -G ${NON_ROOT_GROUP} -s /bin/sh ${NON_ROOT_USER} \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp \
    && chown -R ${NON_ROOT_USER}:${NON_ROOT_GROUP} /config/caddy /data/caddy

COPY ./config/php/local.ini /usr/local/etc/php/conf.d/local.ini

WORKDIR /app

USER ${NON_ROOT_USER}

EXPOSE 80 443 443/udp
