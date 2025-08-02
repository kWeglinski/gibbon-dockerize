
FROM php:8.1-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    mysql-client \
    curl \
    git \
    zip \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    libxml2-dev

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd intl zip opcache

# Configure PHP
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Create non-root user
RUN addgroup -g 1000 www && adduser -u 1000 -G www -s /bin/sh -D www

# Set working directory
WORKDIR /var/www/html

# Copy application files (read-only)
COPY --chown=www:www ../ .

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/uploads && \
    chown -R www:www /var/www/html/uploads && \
    chmod 755 /var/www/html/uploads

# Copy custom PHP configuration
COPY --chown=www:www php.ini /usr/local/etc/php/conf.d/custom.ini

# Expose port
EXPOSE 9000

# Switch to non-root user
USER www

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/ || exit 1

# Start PHP-FPM
CMD ["php-fpm"]
