ARG PHP_VERSION=8.4

FROM rajabilal555/php-base:${PHP_VERSION} AS app-setup

ARG NON_ROOT_UID=1000
ARG NON_ROOT_GID=1000
ARG NON_ROOT_GROUP=app
ARG NON_ROOT_USER=app

# Set working directory
ENV LARAVEL_PATH=/srv/app
ENV SERVER_NAME=:80
WORKDIR $LARAVEL_PATH

# Switch to non-root 'app' user & install app dependencies
COPY composer.json composer.lock ./
RUN chown -R $NON_ROOT_USER:$NON_ROOT_GROUP $LARAVEL_PATH
COPY package.json package-lock.json ./
RUN chown -R $NON_ROOT_USER:$NON_ROOT_GROUP $LARAVEL_PATH
USER $NON_ROOT_USER

# Dev deps only for local image builds. Demo refresh runs outside the container
ARG APP_ENV=${APP_ENV:-production}
RUN if [ "$APP_ENV" = "local" ]; then \
        composer install --prefer-dist --no-scripts --no-autoloader --no-interaction; \
    else \
        composer install --prefer-dist --no-scripts --no-dev --no-autoloader --no-interaction; \
    fi
RUN rm -rf /home/$NON_ROOT_USER/.composer

RUN npm install

# Copy app
COPY --chown=$NON_ROOT_USER:$NON_ROOT_GROUP . $LARAVEL_PATH/
COPY ./.deploy/config/php/local.ini /usr/local/etc/php/conf.d/local.ini

RUN npm run build

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sf http://localhost/ || exit 1

COPY ./.deploy/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
