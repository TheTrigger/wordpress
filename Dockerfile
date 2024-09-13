FROM wordpress:php8.3-fpm-alpine

RUN apk add --no-cache libpng libjpeg-turbo freetype nano libxml2 libxml2-dev zip libzip libzip-dev supercronic

RUN docker-php-ext-install zip opcache mysqli pdo pdo_mysql soap

RUN docker-php-ext-enable opcache

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

# Installazione di WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

USER www-data

RUN echo "* * * * * wp cron event run --due-now --path=/var/www/html" > /home/www-data/crontab

WORKDIR /var/www/html

ARG MAINTAINER
ARG BUILD_DATE
ARG CI_COMMIT_SHA

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE
ENV CI_COMMIT_SHA $CI_COMMIT_SHA

ENTRYPOINT ["startup.sh"]