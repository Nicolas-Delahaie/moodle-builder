FROM php:8.1-apache AS base

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libldap2-dev \
    unzip \
    git \
    --no-install-recommends

RUN docker-php-ext-configure gd --with-jpeg \
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
    exif

RUN docker-php-ext-enable \
    opcache 

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/php.ini &&\
    echo "upload_max_filesize = 128M" >> /usr/local/etc/php/php.ini &&\
    echo "post_max_size = 128M" >> /usr/local/etc/php/php.ini

WORKDIR /var/www/


FROM base AS restored-moodle
COPY --chown=www-data:www-data ./moodle.zip /tmp/moodle.zip
COPY --chown=www-data:www-data ./moodledata.zip /tmp/moodledata.zip

RUN chown www-data:www-data .

USER www-data

RUN unzip -q -o /tmp/moodle.zip -d /var/www/html &&\
    unzip -q -o /tmp/moodledata.zip -d /var/www/moodledata &&\
    rm /tmp/moodle.zip /tmp/moodledata.zip

USER root
COPY --chown=www-data ./config.php html
USER www-data

FROM base AS cloned-moodle

ARG MOODLE_VERSION

RUN chown www-data:www-data .

USER www-data

# Cloning moodle project
RUN test -n "$MOODLE_VERSION" || (echo "Missing arg !" && exit 1) &&\
    git clone --single-branch -b ${MOODLE_VERSION} git://git.moodle.org/moodle.git html
COPY --chown=www-data ./config.php html

# Adds french language pack into moodledata (created)
# from https://download.moodle.org/download.php/langpack/4.5/fr.zip
COPY ./fr.zip /tmp/fr.zip
RUN unzip -o /tmp/fr.zip -d /tmp/fr && \
    mkdir -p moodledata/lang/fr &&\
    cp -R /tmp/fr/* moodledata/lang &&\
    chmod -R 0777 moodledata/lang/fr