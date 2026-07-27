#!/bin/sh

composer dump-autoload --no-interaction --optimize

mkdir -p \
    "$LARAVEL_PATH/storage/framework/cache/data" \
    "$LARAVEL_PATH/storage/framework/sessions" \
    "$LARAVEL_PATH/storage/framework/views" \
    "$LARAVEL_PATH/storage/framework/testing" \
    "$LARAVEL_PATH/storage/app/public" \
    "$LARAVEL_PATH/storage/app/private" \
    "$LARAVEL_PATH/storage/logs" \
    "$LARAVEL_PATH/bootstrap/cache"

php artisan storage:link --no-interaction
php artisan migrate --no-interaction --force
php artisan optimize --no-interaction

export SERVER_ROOT="${LARAVEL_PATH}/public"

exec supervisord -c "$LARAVEL_PATH/.deploy/config/supervisor.conf"
