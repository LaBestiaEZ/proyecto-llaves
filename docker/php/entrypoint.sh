#!/bin/sh
set -e

echo "🔧 Instalando dependencias de Composer..."
composer install --no-dev --optimize-autoloader

echo "🗄️ Ejecutando migraciones de base de datos..."
php bin/console doctrine:migrations:migrate --no-interaction

echo "👤 Creando usuario administrador por defecto..."
php bin/console app:create-admin || echo "Usuario ya existe o comando no disponible"

echo "🧹 Limpiando caché de Symfony..."
php bin/console cache:clear --env=prod

echo "✅ Iniciando PHP-FPM..."
exec php-fpm
