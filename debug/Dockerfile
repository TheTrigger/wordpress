FROM wordpress:php7.4-apache

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
	apt-get install -y apt-utils libxml2-dev zip libzip-dev wget cron libmcrypt-dev && \
	apt-get clean -y && \
	docker-php-ext-install soap zip && \
	pecl install mcrypt-1.0.3 && \
	docker-php-ext-enable mcrypt

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# debug section
RUN pecl install "xdebug" docker-php-ext-enable xdebug


# mah https://r.je/sendmail-php-docker
## start sendmail daemon
#RUN echo "@reboot service sendmail start >/dev/null 2>&1" >> /tmp/tmpcron && \
#	crontab /tmp/tmpcron && \
#	rm /tmp/tmpcron
#RUN echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini

# apt install sendmail
#RUN sed -i '/#!\/bin\/sh/aservice sendmail restart' /usr/local/bin/docker-php-entrypoint
#RUN sed -i '/#!\/bin\/sh/aecho "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts' /usr/local/bin/docker-php-entrypoint


# ping crontab
RUN echo "* * * * * wget -q -O - http://127.0.0.1/wp-cron.php?doing_wp_cron >/dev/null 2>&1" >> /tmp/tmpcron && \
	crontab -u www-data /tmp/tmpcron && \
	rm /tmp/tmpcron

ARG MAINTAINER
ARG BUILD_DATE

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE

CMD cron && apache2-foreground