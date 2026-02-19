FROM dunglas/frankenphp:php8.2-bookworm

RUN install-php-extensions \
    ctype curl dom fileinfo filter hash mbstring openssl pcre pdo \
    session tokenizer xml calendar gd zip imap opcache intl

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get update && apt-get install -y git unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN composer install --optimize-autoloader --no-scripts --no-interaction

RUN npm install && npm run build

RUN mkdir -p storage/framework/{sessions,views,cache,testing} storage/logs bootstrap/cache \
    && chmod -R a+rw storage

CMD ["/start-container.sh"]
