FROM rajabilal555/php-base:php-8.4 AS app-setup

# Set working directory
ENV LARAVEL_PATH=/srv/app
ENV SERVER_NAME=:80
WORKDIR $LARAVEL_PATH

# APP_USER / APP_UID / APP_GID inherited from php-base image
COPY composer.json composer.lock ./
RUN chown -R ${APP_USER}:${APP_USER} $LARAVEL_PATH
COPY package.json package-lock.json ./
RUN chown -R ${APP_USER}:${APP_USER} $LARAVEL_PATH
USER ${APP_USER}

# Dev deps only for local image builds. Demo refresh runs outside the container
ARG APP_ENV=${APP_ENV:-production}
RUN if [ "$APP_ENV" = "local" ]; then \
        composer install --prefer-dist --no-scripts --no-autoloader --no-interaction; \
    else \
        composer install --prefer-dist --no-scripts --no-dev --no-autoloader --no-interaction; \
    fi
RUN rm -rf /home/${APP_USER}/.composer

RUN npm install

# Copy app
COPY --chown=${APP_USER}:${APP_USER} . $LARAVEL_PATH/
COPY ./.deploy/config/php/local.ini /usr/local/etc/php/conf.d/local.ini

RUN npm run build

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sf http://localhost/ || exit 1

COPY ./.deploy/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
