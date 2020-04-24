ARG IMAGINARY_VERSION=1
ARG PHP_VERSION=7.4

FROM h2non/imaginary:${IMAGINARY_VERSION} as imaginary

FROM php:${PHP_VERSION}-fpm

ENV APPLICATION_USER=www-data \
    APPLICATION_GROUP=www-data \
    WEB_DOCUMENT_ROOT=/var/www/html \
    PORT=80

WORKDIR $WEB_DOCUMENT_ROOT

# Add imaginary binaries
COPY --from=imaginary /usr/local/lib /usr/local/lib
COPY --from=imaginary /usr/local/bin/imaginary /usr/local/bin/imaginary
COPY --from=imaginary /etc/ssl/certs /etc/ssl/certs

# Install runtime dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    && apt-get install --no-install-recommends -y \
    libglib2.0-0 \
    libjpeg62-turbo \
    libpng16-16 \
    libopenexr23 \
    libwebp6 \
    libwebpmux3 \
    libwebpdemux2 \
    libtiff5 \
    libgif7 \
    libexif12 \
    libxml2 \
    libpoppler-glib8 \
    libmagickwand-6.q16-6 \
    libpango1.0-0 \
    libmatio4 \
    libopenslide0 \
    libgsf-1-114 \
    fftw3 \
    liborc-0.4-0 \
    librsvg2-2 \
    libcfitsio7 \
    nginx \
    supervisor \
    curl \
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
    && pecl install apcu \
    && pecl install yaml \
    && docker-php-ext-enable apcu yaml \
    && apt-get autoremove -y \
    && apt-get autoclean \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /etc/nginx/conf.d/default.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping

# Add custom nginx configs
COPY conf/php.ini $PHP_INI_DIR/conf.d/custom.ini
COPY conf/fpm-www.conf $PHP_INI_DIR/../php-fpm.d/www.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
