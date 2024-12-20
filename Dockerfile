FROM composer:2.7 AS build

COPY . /app/
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-calendar --ignore-platform-req=ext-gd

FROM php:8.1.31-apache

RUN echo "deb https://mirrors.aliyun.com/debian bookworm main non-free contrib" > /etc/apt/sources.list \
    && echo "deb https://mirrors.aliyun.com/debian bookworm-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb https://mirrors.aliyun.com/debian bookworm-proposed-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb https://mirrors.aliyun.com/debian bookworm-backports main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb https://mirrors.aliyun.com/debian bookworm-backports-sloppy main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src https://mirrors.aliyun.com/debian bookworm main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src https://mirrors.aliyun.com/debian bookworm-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src https://mirrors.aliyun.com/debian bookworm-proposed-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src https://mirrors.aliyun.com/debian bookworm-backports main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src https://mirrors.aliyun.com/debian bookworm-backports-sloppy main non-free contrib" >> /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libfreetype6-dev \
    libicu-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libzip-dev \
    unzip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*  # 清理 apt 缓存

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-configure intl && \
    docker-php-ext-install bcmath calendar exif gd gmp intl mysqli pdo pdo_mysql zip

COPY --from=build /app /var/www/html
COPY .env /var/www/html/.env
COPY ./apache.conf /etc/apache2/sites-available/000-default.conf

RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan optimize:clear && \
    php artisan storage:link && \
    php artisan vendor:publish --provider='Webkul\\Core\\Providers\\CoreServiceProvider' --force && \
    chmod -R 777 /var/www/html/storage && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite

EXPOSE 80

CMD ["apache2-foreground"]
