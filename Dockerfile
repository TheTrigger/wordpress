FROM wordpress:php7.4-apache

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
	apt-get install -y nano apt-utils libxml2-dev zip libzip-dev wget cron libapache2-mod-security2 && \
	apt-get clean -y && \
	docker-php-ext-install soap zip && \
	rm -rf /var/lib/apt/lists/*

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY startup.sh /usr/local/bin/
COPY default-ssl.conf /etc/apache2/sites-available/
#COPY ssl.conf /etc/apache2/mods-available/ssl.conf

## SSL local dev

# non funzionerebbe a causa del nome dominio
RUN mkdir -p /etc/apache2/ssl/
RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
	"/C=IT/ST=FC/L=CESENA/O=OIBI.DEV/CN=localhost" \
	-keyout /etc/apache2/ssl/ssl.key -out /etc/apache2/ssl/ssl.crt

# trusted cert but no luck with domain names
#RUN cp /etc/apache2/ssl/ssl.crt /usr/local/share/ca-certificates/
#RUN update-ca-certificates

## END SSL

RUN echo "insecure" >> $HOME/.curlrc

## enable self signed ssl
RUN a2enmod rewrite ssl security2
RUN a2ensite default-ssl

# ping crontab
RUN echo "* * * * * curl http://127.0.0.1/wp-cron.php?doing_wp_cron" >> /tmp/tmpcron && \
	crontab -u www-data /tmp/tmpcron && rm /tmp/tmpcron

ENTRYPOINT ["startup.sh"]
CMD ["apache2-foreground"]

ARG MAINTAINER
ARG BUILD_DATE

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE