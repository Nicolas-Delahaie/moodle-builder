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