#!/bin/bash

set -e

# Update packages
apt-get update

# Install system dependencies
apt-get install php7.4 php7.4-cli php7.4-json php7.4-opcache php7.4-mysql php7.4-curl -y
apt-get install php7.4-zip php7.4-fpm php7.4-mbstring php7.4-dom php7.4-intl php7.4-gd -y
apt-get install php7.4-bcmath php7.4-soap -y

# Enable PHP extensions
docker-php-ext-install \
    pdo_mysql \
    intl \
    zip \
    soap \
    xsl \
    bcmath \
    gd

# Configure GD for image handling
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install gd

# Clean up
apt-get clean && rm -rf /var/lib/apt/lists/*
