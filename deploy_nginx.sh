#!/usr/bin/env bash

NGINX="Nginx"
PHP="PHP-Nginx"
NGINXD="nginx:latest"
PHPD="php:7.4.20-fpm-buster"

PATHNGINX="/home/suporte/resources/nginx"
DOCKER="/usr/bin/docker"
MKDIR="/usr/bin/mkdir"
APT="/usr/bin/apt"


if [[ -d $PATHNGINX && -d $PATHNGINX/conf && -d $PATHNGINX/log && -d $PATHNGINX/www/default ]]; then
   echo "Diretorios existente."
   else
      $MKDIR -p $PATHNGINX $PATHNGINX/conf $PATHNGINX/log $PATHNGINX/www/default
      echo "Diretorios criado."
fi


### Remove
$DOCKER stop $NGINX && \
	$DOCKER rm $NGINX && \
	$DOCKER rmi $NGINXD && \ 
	$DOCKER stop $PHP && \
	$DOCKER rm $PHP && \
	$DOCKER rmi $PHPD

### Install
$DOCKER run --name $PHP \
	-e TZ='America/Sao_Paulo' \
	-e PHP_MEMORY_LIMIT=128M \
	-v $PATHNGINX/www:/usr/share/nginx/html \
	-v $PATHNGINX/conf/php.ini:/usr/local/etc/php/php.ini \
	--restart unless-stopped \
	-d $PHPD

$DOCKER exec -u 0 $PHP /bin/bash -c \ 
	"apt update; \
	apt install libmcrypt-dev libldap2-dev zlib1g-dev libpng-dev libicu-dev libxml++2.6-dev libzip-dev libbz2-dev -y; \
	apt autoclean; apt autoremove; \
	docker-php-ext-install ldap bcmath gd intl mysqli opcache xmlrpc exif zip bz2; \
	docker-php-ext-enable ldap bcmath gd intl mysqli opcache xmlrpc exif zip bz2; \
	pecl install apcu mcrypt; \
	docker-php-ext-enable apcu mcrypt"
       
$DOCKER restart $PHP

$DOCKER run --name $NGINX \
	--link $PHP:PHP \
	-p 8082:80 \
	-e TZ='America/Sao_Paulo' \
	-v $PATHNGINX/conf/nginx.conf:/etc/nginx/nginx.conf:ro \
	-v $PATHNGINX/conf/default.conf:/etc/nginx/conf.d/default.conf:ro \
	-v $PATHNGINX/www:/usr/share/nginx/html \
	-v $PATHNGINX/log:/var/log/nginx \
	--restart unless-stopped \
	-d $NGINXD








