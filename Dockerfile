FROM wordpress:php8.4-fpm-alpine

# Aggiorna i pacchetti di sistema per risolvere vulnerabilità
RUN apk upgrade --no-cache

# Installa dipendenze e estensioni PHP
RUN apk add --no-cache --virtual .build-deps libxml2-dev \
	&& apk add --no-cache nano libxml2 supercronic \
	&& docker-php-ext-install pdo_mysql soap ftp \
	&& docker-php-ext-enable pdo_mysql soap ftp \
	&& apk del .build-deps

# Copia configurazioni PHP
COPY php/wpcli.ini /usr/local/etc/php/wpcli.ini
COPY php/conf.d/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY php/conf.d-wpcli/ /usr/local/etc/php/conf.d-wpcli/

# Copia startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Installa WP-CLI e crea alias
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp.phar \
	&& chmod +x /usr/local/bin/wp.phar \
	&& printf '#!/bin/sh\nPHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/usr/local/etc/php/conf.d-wpcli exec php -c /usr/local/etc/php/wpcli.ini /usr/local/bin/wp.phar "$@"\n' > /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

# Crea la cartella per le sessioni PHP
RUN mkdir -p /home/www-data/sessions \
	&& chown www-data:www-data /home/www-data/sessions \
	&& chmod 700 /home/www-data/sessions

# Configura healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
	CMD php-fpm -t || exit 1

USER www-data

# Configura crontab per WP-CLI (con check se WordPress è installato)
RUN echo 'SHELL=/bin/sh\n' \
	'HOME=/var/www/html\n' \
	'WP_CLI_CACHE_DIR=/var/www/html/wp-content/.wp-cli/cache\n' \
	'* * * * * [ -f /var/www/html/wp-config.php ] && /usr/local/bin/wp cron event run --due-now --path=/var/www/html --quiet\n' \
	> /home/www-data/crontab

WORKDIR /var/www/html

ARG MAINTAINER=""
ARG BUILD_DATE=""
ARG CI_COMMIT_SHA=""
ARG VERSION="1.0.0"

# OCI Image Format Specification Labels
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
	org.opencontainers.image.authors="${MAINTAINER}" \
	org.opencontainers.image.url="https://github.com/yourusername/wordpress" \
	org.opencontainers.image.documentation="https://github.com/thetrigger" \
	org.opencontainers.image.source="https://github.com/thetrigger" \
	org.opencontainers.image.version="${VERSION}" \
	org.opencontainers.image.revision="${CI_COMMIT_SHA}" \
	org.opencontainers.image.vendor="FABRIZI.SOFTWARE" \
	org.opencontainers.image.title="WordPress FPM Alpine" \
	org.opencontainers.image.description="Optimized WordPress PHP-FPM on Alpine Linux with WP-CLI and security hardening" \
	org.opencontainers.image.base.name="wordpress:php8.4-fpm-alpine"

ENV MAINTAINER=$MAINTAINER \
	BUILD_DATE=$BUILD_DATE \
	CI_COMMIT_SHA=$CI_COMMIT_SHA

ENTRYPOINT ["startup.sh"]
CMD ["php-fpm"]

EXPOSE 9000