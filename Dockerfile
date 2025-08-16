
FROM php:8.1-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
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
    gettext-dev \
    libxml2-dev \
    oniguruma-dev

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gettext gd intl zip opcache soap xml

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
COPY --chown=www:www gibbon-core/. /var/www/html/

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/uploads && \
    chown -R www:www /var/www/html/uploads && \
    chmod 755 /var/www/html/uploads

# Copy custom PHP configuration
# Assuming custom php.ini is placed at project root; adjust if located elsewhere
COPY --chown=www:www php.ini /usr/local/etc/php/conf.d/custom.ini

# Configure PHP-FPM to listen on TCP for Nginx
RUN echo 'listen = 0.0.0.0:9000' >> /usr/local/etc/php-fpm.d/zz-docker.conf
# Expose port
EXPOSE 9000

# Switch to non-root user
USER www

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f --unix-socket /run/php/php8.1-fpm.sock http://localhost/status || exit 1

# Start PHP-FPM
CMD ["php-fpm"]
