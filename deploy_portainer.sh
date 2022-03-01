#!/usr/bin/env bash

PORTAINER="/home/suporte/resources/portainer"
DOCKER="/usr/bin/docker"
MKDIR="/usr/bin/mkdir"


if [[ -d $PORTAINER ]]; then
   echo "Diretorio existente"
   else
      $MKDIR -p $PORTAINER
      echo "Diretorio criado"
fi


### REMOVE
$DOCKER stop Portainer && \
	$DOCKER rm Portainer && \
	$DOCKER rmi portainer/portainer-ce


### INSTALL
$DOCKER run --name Portainer \
	-p 9000:9000 \
	-e TZ='America/Sao_Paulo' \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $PORTAINER:/data \
	--restart unless-stopped \
	-d portainer/portainer-ce



