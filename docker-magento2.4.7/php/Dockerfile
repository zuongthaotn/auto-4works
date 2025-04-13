FROM php:8.3-fpm

COPY install-php-extensions.sh /usr/local/bin/install-php-extensions.sh
RUN chmod +x /usr/local/bin/install-php-extensions.sh \
    && /usr/local/bin/install-php-extensions.sh
