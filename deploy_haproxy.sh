#!/usr/bin/env bash

HAPROXY="/home/suporte/resources/haproxy"
CERTS="/home/suporte/resources/haproxy/certs"
DOCKER="/usr/bin/docker"
MKDIR="/usr/bin/mkdir"


if [[ -d $CERTS ]]; then 
   echo "Diretorios existente."
   else 
      $MKDIR -p $CERTS
      echo "Diretorios criado."
fi


### Remove
$DOCKER stop HAProxy && \
	$DOCKER rm HAProxy && \
	$DOCKER rmi haproxytech/haproxy-debian:latest


### Install
$DOCKER run --name HAProxy \
	-p 80:80 -p 443:443 -p 1936:1936 \
	-e TZ='America/Sao_Paulo' \
	-v $HAPROXY:/usr/local/etc/haproxy:ro \
	-v $CERTS:/etc/ssl/private:ro \
	--restart unless-stopped \
	-d haproxytech/haproxy-debian:latest



