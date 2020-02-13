FROM php:7.4-apache

ENV APPLICATION_USER=www-data \
    APPLICATION_GROUP=www-data \
    WEB_DOCUMENT_ROOT=/app \
    PORT=80

RUN sed -ri -e 's!/var/www/html!${WEB_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${WEB_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && sed -ri 's/80/${PORT}/g' /etc/apache2/sites-available/*.conf /etc/apache2/ports.conf \
    && a2enmod \
        rewrite \
        deflate \
        expires \
        actions \
        proxy \
        proxy_http \
        proxy_fcgi \
        ssl \
        headers \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libyaml-dev \
        libzip4 \
        libzip-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        git \
        cron \
        nano \
    && docker-php-ext-install opcache \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/* \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && { \
            echo 'opcache.memory_consumption=512'; \
            echo 'opcache.interned_strings_buffer=16'; \
            echo 'opcache.max_accelerated_files=13370'; \
            echo 'opcache.revalidate_freq=2'; \
            echo 'opcache.fast_shutdown=1'; \
            echo 'opcache.enable_cli=1'; \
            echo 'upload_max_filesize=256M'; \
            echo 'post_max_size=256M'; \
            echo 'memory_limit=2048M'; \
            echo 'max_execution_time=180'; \
        } > $PHP_INI_DIR/conf.d/php-custom.ini \
    && pecl install apcu \
    && pecl install yaml \
    && docker-php-ext-enable apcu yaml \
    && php -i
