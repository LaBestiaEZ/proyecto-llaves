#!/bin/sh
set -e

# Ejecutar migraciones
cd /var/www/backend
php bin/console doctrine:migrations:migrate --no-interaction

# Iniciar PHP-FPM en background
php-fpm -D

# Iniciar Nginx en foreground
nginx -g "daemon off;"
