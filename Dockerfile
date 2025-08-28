FROM php:8.1-apache

RUN apt-get update \
    && apt-get upgrade -y

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get install -y libzip-dev unzip

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN docker-php-ext-install zip mysqli

ENV APACHE_DOCUMENT_ROOT /var/www/html/Public

# install the ssl-cert package which will create a "snakeoil" keypair
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y ssl-cert \
 && rm -r /var/lib/apt/lists/*

# enable ssl module and enable the default-ssl site
RUN a2enmod ssl
RUN ln -s /etc/apache2/sites-available/wbengine.conf /etc/apache2/sites-enabled/wbengine.conf
#RUN a2ensite elkplana.cz

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/default-ssl.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
#RUN echo zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20190902/xdebug.so >> "$PHP_INI_DIR/php.ini"
#RUN find /usr/local/lib/php/ -name "xdebug.so" | grep no-debug-non-zts- | xargs -I {} -n 1 echo "zend_extension="{} >> "$PHP_INI_DIR/php.ini"

# WORKDIR /var/www/html
# COPY . ./
# COPY ./src/Config/settings.json.default ./src/Config/Settings.json
# RUN chown root:www-data -R ./src/View/Compiled/ && chmod g+w -R src/View/Compiled/
# RUN composer install

# RUN mkdir /var/www/html/src/View/Compiled/
# RUN chmod 777 /var/www/html/src/View/Compiled/