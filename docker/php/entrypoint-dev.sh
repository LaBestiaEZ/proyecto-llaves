#!/bin/sh
set -e

echo "🔧 Instalando dependencias de Composer (con dev)..."
composer install --optimize-autoloader

echo "🗄️ Creando base de datos si no existe..."
php bin/console doctrine:database:create --if-not-exists --no-interaction

echo "🗄️ Ejecutando migraciones de base de datos..."
php bin/console doctrine:migrations:migrate --no-interaction

echo "👤 Creando usuario administrador por defecto..."
php bin/console app:create-admin || echo "Usuario ya existe o comando no disponible"

echo "🧹 Limpiando caché de Symfony..."
php bin/console cache:clear --env=dev

echo "✅ Iniciando PHP-FPM..."
exec php-fpm
