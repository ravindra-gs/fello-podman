FROM php:7.4-fpm

# Install7Composer
COPY --from=composer:lts /usr/bin/composer /usr/bin/composer

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    locales \
    unzip \
    zip \
    libzip-dev \
    libxrender1 \
    libfontconfig1 \
    libfreetype6 \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Install Xdebug for development
# RUN pecl install xdebug-3.3.1 && \
#     docker-php-ext-enable xdebug

# Copy PHP-FPM configuration
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

COPY xdebug.ini /usr/local/etc/php/conf.d/

# Copy PHP configuration files
RUN echo "max_execution_time=300" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "upload_max_filesize=100M" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "post_max_size=100M" >> /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www

EXPOSE 8074

CMD ["php-fpm", "-F", "--allow-to-run-as-root"]
