FROM php:8.4-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip git libzip-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install mysqli zip \
    && a2enmod rewrite ssl

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY etc/apache2/sites-available/wbengine.conf /etc/apache2/sites-available/000-default.conf

# Development settings. For production use php.ini-production instead.
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html
COPY bin/container-entrypoint.sh /usr/local/bin/wbengine-container-entrypoint
RUN chmod 0755 /usr/local/bin/wbengine-container-entrypoint
ENTRYPOINT ["/usr/local/bin/wbengine-container-entrypoint"]
CMD ["apache2-foreground"]
