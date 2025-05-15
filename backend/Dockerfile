FROM php:8.2-apache

# Installa le dipendenze necessarie
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Installa le estensioni PHP necessarie
RUN docker-php-ext-install pdo pdo_mysql mysqli zip exif

# Abilita il modulo rewrite di Apache
RUN a2enmod rewrite

# Configura il document root di Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}/!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copia il file di configurazione PHP personalizzato (opzionale)
COPY ./config/php.ini /usr/local/etc/php/conf.d/custom.ini

# Imposta le autorizzazioni corrette
RUN chown -R www-data:www-data /var/www/html

# Espone la porta 80
EXPOSE 80

# Avvia Apache in foreground
CMD ["apache2-foreground"]