FROM wordpress:php8.3-fpm-alpine

RUN apk add --no-cache \
	libpng \
	libjpeg-turbo \
	freetype \
	libzip

RUN apk add --no-cache nano libxml2 libxml2-dev zip libzip libzip-dev wget dcron

RUN docker-php-ext-install zip opcache mysqli pdo pdo_mysql soap
#RUN docker-php-ext-install sockets

RUN docker-php-ext-enable opcache
#RUN docker-php-ext-enable opcache sockets

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

# Installazione di WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# ping crontab
RUN echo "* * * * * wp cron event run --due-now --path=/var/www/html" | crontab -u www-data -

#RUN chown -R www-data:www-data /var/www/html
USER www-data
WORKDIR /var/www/html

ARG MAINTAINER
ARG BUILD_DATE
ARG CI_COMMIT_SHA

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE
ENV CI_COMMIT_SHA $CI_COMMIT_SHA