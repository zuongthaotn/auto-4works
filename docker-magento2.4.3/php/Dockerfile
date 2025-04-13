FROM php:7.4-fpm

COPY install-php-extensions.sh /usr/local/bin/install-php-extensions.sh
RUN chmod +x /usr/local/bin/install-php-extensions.sh \
    && /usr/local/bin/install-php-extensions.sh
