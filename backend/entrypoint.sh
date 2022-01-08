#!/bin/sh
set -e

cd /app
composer install --no-interaction --no-ansi --no-suggest --prefer-dist --no-autoloader --no-scripts
composer dump
php artisan migrate
php artisan db:seed

exec "$@"
