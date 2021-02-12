FROM wordpress:php7.4-apache

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
	apt-get install -y apt-utils libxml2-dev zip libzip-dev wget cron && \
	apt-get clean -y && \
	docker-php-ext-install soap zip

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# enable self signed ssl
RUN a2enmod ssl

# ping crontab
RUN echo "* * * * * wget -q -O - http://127.0.0.1/wp-cron.php?doing_wp_cron >/dev/null 2>&1" >> /tmp/tmpcron && \
	crontab -u www-data /tmp/tmpcron && rm /tmp/tmpcron

ARG MAINTAINER
ARG BUILD_DATE

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE

CMD cron && apache2-foreground