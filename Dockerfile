FROM dunglas/frankenphp:php8.2-bookworm

# PHP Extensions
RUN install-php-extensions \
    ctype curl dom fileinfo filter hash mbstring openssl pcre pdo \
    session tokenizer xml calendar gd zip imap opcache intl

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs git unzip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY . .

RUN composer install --optimize-autoloader --no-scripts --no-interaction

RUN npm install && npm run build

RUN mkdir -p storage/framework/{sessions,views,cache,testing} storage/logs bootstrap/cache \
    && chmod -R a+rw storage

RUN printf '{\n    frankenphp\n}\n\n:{$PORT:80} {\n    root * /app/public\n    encode zstd gzip\n    php_server\n    file_server\n}\n' > /etc/caddy/Caddyfile

EXPOSE 8080

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
