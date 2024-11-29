FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libldap2-dev \
    unzip \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install \
    mysqli \
    pdo_mysql \
    gd \
    zip \
    intl \
    soap \
    mbstring \
    opcache \
    xml \
    bcmath \
    && docker-php-ext-enable \
    opcache

RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/php.ini

WORKDIR /var/www/

# Copy moodle project
COPY --chown=www-data:www-data ./moodle html

# Give permissions to moodledata/, before persisting
RUN mkdir moodledata
RUN chown -R www-data:www-data moodledata

# Copy DB configuration
COPY --chown=www-data ./config.php /var/www/