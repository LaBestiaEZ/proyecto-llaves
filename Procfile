release: cd backend && php bin/console doctrine:migrations:migrate --no-interaction
web: cd backend && php-fpm -D && nginx -g "daemon off;"
