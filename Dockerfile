FROM wordpress:php8.4-fpm-alpine

# Aggiorna i pacchetti di sistema per risolvere vulnerabilità
RUN apk upgrade --no-cache

RUN apk add --no-cache --virtual .build-deps libxml2-dev \
	&& apk add --no-cache nano libxml2 supercronic \
	&& docker-php-ext-install pdo_mysql soap ftp \
	&& docker-php-ext-enable pdo_mysql soap ftp \
	&& apk del .build-deps

COPY php/wpcli.ini /usr/local/etc/php/wpcli.ini
COPY php/conf.d/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY php/conf.d-wpcli/ /usr/local/etc/php/conf.d-wpcli/

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

# Installazione di WP CLI
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp.phar \
	&& chmod +x /usr/local/bin/wp.phar \
	&& printf '#!/bin/sh\nPHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/usr/local/etc/php/conf.d-wpcli exec php -c /usr/local/etc/php/wpcli.ini /usr/local/bin/wp.phar "$@"\n' > /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

USER www-data

RUN echo 'SHELL=/bin/sh\n' \
	'HOME=/var/www/html\n' \
	'WP_CLI_CACHE_DIR=/var/www/html/wp-content/.wp-cli/cache\n' \
	'* * * * * /usr/local/bin/wp cron event run --due-now --path=/var/www/html --quiet\n' \
	> /home/www-data/crontab

WORKDIR /var/www/html

ARG MAINTAINER
ARG BUILD_DATE
ARG CI_COMMIT_SHA

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE
ENV CI_COMMIT_SHA $CI_COMMIT_SHA

ENTRYPOINT ["startup.sh"]
CMD ["php-fpm"]

EXPOSE 9000