FROM wordpress:php7.4-apache

RUN apt-get update -y && \
	apt-get install -y libxml2-dev zip libzip-dev wget cron && \
	apt-get clean -y && \
	docker-php-ext-install soap && docker-php-ext-install zip

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# ping crontab
RUN echo "* * * * * wget -q -O - http://127.0.0.1/wp-cron.php?doing_wp_cron >/dev/null 2>&1" >> /tmp/tmpcron && \
	crontab -u www-data /tmp/tmpcron && rm /tmp/tmpcron

ARG MAINTAINER
ARG BUILD_DATE

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE

CMD cron && apache2-foreground