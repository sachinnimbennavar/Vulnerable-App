FROM php:8.0-apache

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    sqlite3 \
    libsqlite3-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd pdo pdo_sqlite mysqli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Vulnerable: Set ServerTokens to expose server information
RUN echo "ServerTokens Full" >> /etc/apache2/apache2.conf && \
    echo "ServerSignature On" >> /etc/apache2/apache2.conf

# Install Composer (older vulnerable version for demo)
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.22 --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Copy Apache configuration
COPY httpd.conf /etc/apache2/sites-available/000-default.conf

# Set permissions (VULNERABLE - overly permissive)
RUN chmod -R 777 /var/www/html

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
