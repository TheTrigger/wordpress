FROM wordpress:php7.4-apache

RUN apt-get update -y
RUN apt-get install -y libxml2-dev zip libzip-dev wget cron ca-certificates
RUN apt-get clean -y
RUN docker-php-ext-install soap
RUN docker-php-ext-install zip

# ping crontab
RUN echo "* * * * * wget -q http://127.0.0.1/wp-cron.php?doing_wp_cron" >> /tmp/tmpcron
RUN crontab -u www-data /tmp/tmpcron
RUN rm /tmp/tmpcron

ARG MAINTAINER
ARG BUILD_DATE

ENV MAINTAINER $MAINTAINER
ENV BUILD_DATE $BUILD_DATE
