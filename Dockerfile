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
    exif \
    && docker-php-ext-enable \
    opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/php.ini

WORKDIR /var/www/

# Copy moodle project (including custom config)
COPY --chown=www-data:www-data ./moodle html
COPY --chown=www-data ./config.php html

RUN chown www-data:www-data .

USER www-data

# from https://download.moodle.org/download.php/langpack/4.5/fr.zip
COPY ./fr.zip /tmp/fr.zip

# Creates moodledata/ and adds french language pack
RUN unzip -o /tmp/fr.zip -d /tmp/fr && \
    mkdir -p moodledata/lang/fr &&\
    cp -R /tmp/fr/* moodledata/lang &&\
    chmod -R 0777 moodledata/lang/fr