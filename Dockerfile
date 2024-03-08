FROM php:7.4.1-apache

RUN apt-get update && apt-get upgrade -y --no-install-recommends dialog apt-utils
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get install -y mc vim libzip-dev git zip unzip && docker-php-ext-install zip

#RUN pecl install xdebug

RUN docker-php-ext-install mysqli
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite deflate expires
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

## RUN echo zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20190902/xdebug.so >> "$PHP_INI_DIR/php.ini"
# RUN find /usr/local/lib/php/ -name "xdebug.so" | grep no-debug-non-zts- | xargs -I {} -n 1 echo "zend_extension="{} >> "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html
# New file include apache expires and apache configuration
COPY ./etc/apache/docker-php.conf /etc/apache2/conf-available/docker-php.conf

# Copy all project files to container...
COPY . ./
COPY ./src/Config/settings.json.default ./src/Config/Settings.json

# Update right owner permition on compiler cached files
RUN chown root:www-data -R ./src/View/Compiled/ && chmod g+w -R src/View/Compiled/

# Install required dependencies...
RUN composer install
