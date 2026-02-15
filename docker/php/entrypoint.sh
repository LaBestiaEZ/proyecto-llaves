#!/bin/sh
set -e

echo "Installing Composer dependencies (production)..."
composer install --no-dev --optimize-autoloader

echo "Generating JWT keys..."
if [ ! -f config/jwt/private.pem ]; then
    mkdir -p config/jwt
    php bin/console lexik:jwt:generate-keypair --skip-if-exists
    echo "JWT keys generated successfully"
else
    echo "JWT keys already exist"
fi

echo "Creating database if not exists..."
php bin/console doctrine:database:create --if-not-exists --no-interaction

echo "Running migrations..."
php bin/console doctrine:migrations:migrate --no-interaction

echo "Creating default admin user..."
php bin/console app:create-admin || echo "User already exists or command not available"

echo "Creating sample data..."
php bin/console app:create-sample-data || echo "Sample data already exists or command not available"

echo "Creating sample products..."
php bin/console app:create-sample-products || echo "Sample products already exist or command not available"

echo "Clearing cache..."
php bin/console cache:clear --env=prod

echo "Warming up cache..."
php bin/console cache:warmup --env=prod

echo "Starting PHP-FPM..."
exec php-fpm
