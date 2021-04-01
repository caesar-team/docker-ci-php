FROM php:7.4-fpm-alpine AS base
LABEL Maintainer="Aleksandr Beshkenade <ab@caesar.team>" \
      Description="Test container with POSTGRESDB."

RUN apk --update add \
    curl \
    supervisor \
    git \
    zip \
    gpgme

RUN apk add --no-cache --no-progress --virtual BUILD_DEPS ${PHPIZE_DEPS}
RUN apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP \
    libzip-dev \
    icu-dev \
    icu-dev \
    gpgme-dev \
    libzip-dev \
    postgresql-dev \
    rabbitmq-c \
    rabbitmq-c-dev

RUN docker-php-ext-install \
    intl \
    bcmath\
    opcache \
    zip \
    sockets \
    pdo \
    pdo_pgsql \
    zip

RUN pecl install gnupg redis amqp \
    && docker-php-ext-enable redis amqp

RUN apk del --no-progress BUILD_DEPS BUILD_DEPS_PHP ${PHPIZE_DEPS}
# Configure composer:2
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV PGDATA /var/lib/postgresql/data
ENV POSTGRES_USER=test
ENV POSTGRES_DB=test
ENV POSTGRES_PASSWORD=test
ENV TEST_POSTGRES_USER=test
ENV TEST_POSTGRES_PASSWORD=test
ENV TEST_DATABASE_HOST=127.0.0.1
ENV TEST_POSTGRES_DB=test

RUN apk --update add su-exec bash postgresql postgresql-client
# this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
RUN mkdir -p "$PGDATA" \
    && chown -R postgres:postgres "$PGDATA" \
    && chmod 777 "$PGDATA" \
    && mkdir /docker-entrypoint-initdb.d
COPY _scripts/init_db.sh /usr/local/bin
COPY _scripts/wait-for-it.sh /usr/local/bin

COPY --chown=www-data:www-data --from=4xxi/php-security-checker /usr/local/bin/local-php-security-checker /usr/local/bin/local-php-security-checker
