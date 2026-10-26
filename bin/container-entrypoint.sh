#!/bin/sh
set -eu
cd /var/www/html

mkdir -p src/View/Compiled
chown www-data:www-data src/View/Compiled
chmod 2775 src/View/Compiled

php bin/wbe install

exec docker-php-entrypoint "$@"
