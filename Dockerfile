FROM php:7.4.1-apache

MAINTAINER SURESH REDDY

USER root

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        libpq-dev \
        zip \
        curl \
        unzip \
        git \   
        npm \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && docker-php-ext-install zip \
    && docker-php-source delete

ARG CACHE=1

# BRANCH_NAME
ARG BRANCH_NAME=''

#BRANCH_NAME varible
ENV BRANCH=${BRANCH_NAME}

RUN git clone -b ${BRANCH} https://oauth2:JpzfRmMkAfLnVd-D1NEv@gitlab.ascent-online.com/pnbhat/input-module-ui.git/ \
                && mv ./input-module-ui/* . \
                && chmod -R 777 storage 

COPY ./vhost.conf /etc/apache2/sites-available/000-default.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
         && apk add --no-cache ffmpeg opus pixman cairo pango giflib ca-certificates \
         && && apk add --no-cache --virtual .build-deps python g++ make gcc .build-deps curl git pixman-dev cairo-dev pangomm-dev libjpeg-turbo-dev giflib-dev \
         && composer install \
         && npm install npm \
         && npm run development \
         && chown -R www-data:www-data /var/www/html \
         && a2enmod rewrite
