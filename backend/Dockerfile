FROM composer:2 AS composer

FROM php:7.4-fpm-alpine


COPY --from=composer /usr/bin/composer /usr/bin/composer

ENV PHPIZE_DEPS \
  build-base \
  autoconf \
  libc-dev \
  pcre-dev \
  openssl \
  pkgconf \
  cmake \
  make \
  file \
  re2c \
  g++ \
  gcc \
  libtool \
  imagemagick-dev

# repmanent deps
ENV PERMANENT_DEPS \
  mysql-dev \
  gettext-dev \
  icu-dev \
  libintl \
  imagemagick

RUN set -xe \
  && apk add --no-cache ${PERMANENT_DEPS} \
  && apk add --no-cache --virtual .build-deps ${PHPIZE_DEPS} \
  && apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv \
  && pecl install imagick-3.4.3 \
  && docker-php-ext-enable imagick \
  && docker-php-ext-configure pdo_mysql \
  && docker-php-ext-configure bcmath --enable-bcmath \
  && docker-php-ext-configure pcntl --enable-pcntl \
  && docker-php-ext-configure intl --enable-intl \
  && docker-php-ext-configure sysvmsg \
  && docker-php-ext-configure sysvsem \
  && docker-php-ext-configure sysvshm \
  && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    sockets \
    gettext \
    bcmath \
    pcntl \
    intl \
    sysvmsg \
    sysvsem \
    sysvshm \
  && apk del .build-deps

#WORKDIR /app
#
#RUN set -xe \
#  && composer install --no-interaction --no-ansi --no-suggest --prefer-dist  --no-autoloader --no-scripts \
#  && composer install --no-dev --no-interaction --no-ansi --no-suggest --prefer-dist  --no-autoloader --no-scripts
#
#RUN composer dump \
#  && php artisan migrate --seed

COPY ./backend/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
CMD ["php-fpm"]
