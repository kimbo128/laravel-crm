FROM dunglas/frankenphp:php8.2-bookworm

RUN install-php-extensions \
    ctype curl dom fileinfo filter hash mbstring openssl pcre pdo \
    session tokenizer xml calendar gd zip imap opcache intl

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs git unzip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY . .

RUN composer install --optimize-autoloader --no-scripts --no-interaction

RUN npm install && npm run build

RUN printf '{\n    frankenphp\n}\n\n:{$PORT:80} {\n    root * /app/public\n    encode zstd gzip\n    php_server\n    file_server\n}\n' > /etc/caddy/Caddyfile

RUN printf '#!/bin/sh\nmkdir -p /app/storage/framework/{sessions,views,cache,testing}\nmkdir -p /app/storage/logs\nmkdir -p /app/bootstrap/cache\nchmod -R 777 /app/storage /app/bootstrap/cache\nphp /app/artisan config:cache\nphp /app/artisan view:cache\nphp /app/artisan migrate --force\nexec frankenphp run --config /etc/caddy/Caddyfile\n' > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
