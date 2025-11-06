# Base image
FROM php:8.1

# Defined working directory
WORKDIR /projet

# Copy Laravel project to /projet
COPY app .

# Installation des dépendances système et extensions PHP
RUN apt update && apt install -y \
    zip \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libpq-dev \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && docker-php-ext-install pdo pgsql pdo_pgsql

# Exposer le port 8000
EXPOSE 8000

# Ajouter un utilisateur 'www' et l'ajouter au groupe 'www'
RUN adduser  www \
    && usermod -aG www www

# Installation des dépendances Composer et génération de la clé Laravel
RUN composer install  \
    && php artisan key:generate

# Donner les permissions aux fichiers et répertoires Laravel
RUN chown -R www:www /projet \
    && chmod -R 775 /projet/storage

# Passer à l'utilisateur 'www'
USER www

# Start main process
ENTRYPOINT ["php", "artisan", "serve", "--host", "0.0.0.0"]

