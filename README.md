# Wordpress FPM + WP-CLI

Built over <https://hub.docker.com/_/wordpress>


# Build

```sh
docker build -t wordpress:fpm .
```


# Fixes

## FTP

<https://github.com/docker-library/php/issues/1488#issuecomment-1906738878>

```sh
FROM php:8.2

RUN apt-get update && apt-get install -y libssl-dev

RUN docker-php-ext-configure ftp --with-openssl-dir=/usr \
	&& docker-php-ext-install ftp
```



## Git revert

Se .git revert potrebbe essere necessario -> `dos2unix`