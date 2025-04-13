#!/bin/bash

set -e

# Update packages
apt-get update

# Install system dependencies
sudo apt install php8.3 php8.3-cli php8.3-opcache php8.3-mysql php8.3-curl php8.3-zip php8.3-fpm php8.3-mbstring php8.3-dom php8.3-intl php8.3-gd php8.3-bcmath php8.3-soap -y

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
