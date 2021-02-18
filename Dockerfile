FROM wordpress:php7.4-apache

	apt-get install -y apt-utils libxml2-dev zip libzip-dev wget cron libapache2-mod-security2 && \

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY ssl.conf /etc/apache2/mods-available/ssl.conf

# enable self signed ssl
RUN a2enmod rewrite ssl security2

# ping crontab
RUN echo "* * * * * wget -q -O - http://127.0.0.1/wp-cron.php?doing_wp_cron >/dev/null 2>&1" >> /tmp/tmpcron
RUN crontab -u www-data /tmp/tmpcron
RUN rm /tmp/tmpcron

ARG MAINTAINER
ARG BUILD_DATE

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE

CMD cron && apache2-foreground