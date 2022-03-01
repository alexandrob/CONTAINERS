#!/usr/bin/env bash

PATHLETS="/home/suporte/resources/letsencrypt"
PATHLETSLOG="/home/suporte/resources/letsencrypt/log"
PATHCERTS="/home/suporte/resources/haproxy/certs"

DOCKER="/usr/bin/docker"
CAT="/bin/cat"

CERTPARAM="--standalone --agree-tos --non-interactive --http-01-port=8083"
CERTEMAIL="--email suporte@expoente.com.br"
CERTDOMAIN="domain.com.br"

CERTPARAMEXP="--expand --standalone --agree-tos --non-interactive --http-01-port=8083" 
# --force-renewal"
CERTDOMAINEXP="-d www.domain.com.br"




######################################
###   FUNCOES   ######################

criar_certificado(){
   echo ""
   echo "### Deploy Certbot   ######################################"
   $DOCKER run --name Certbot \
	-p 8083:8083 \
	-v $PATHLETS:/etc/letsencrypt \
	-v $PATHLETSLOG:/var/log/letsencrypt \
	certbot/certbot:latest \
	certonly $CERTPARAM $CERTEMAIL -d $CERTDOMAIN 
}

expandir_certificado(){
   echo ""
   echo "Novas expansões: " $CERTDOMAINEXP
   echo "" 
   echo "### Deploy Certbot   ######################################"
   $DOCKER run --name Certbot \
	-p 8083:8083 \
	-v $PATHLETS:/etc/letsencrypt \
	-v $PATHLETSLOG:/var/log/letsencrypt \
	certbot/certbot:latest \
	certonly $CERTPARAMEXP $CERTEMAIL -d $CERTDOMAIN $CERTDOMAINEXP
# --force-renewal
}

renovar_certificado(){
   echo ""
   echo "### Deploy Certbot   ######################################"
   $DOCKER run --name Certbot \
	-p 8083:8083 \
	-v $PATHLETS:/etc/letsencrypt \
	-v $PATHLETSLOG:/var/log/letsencrypt \
	certbot/certbot:latest \
	renew 
	   #--force-renewal
}

remover_container(){
   echo ""
   echo "### Removendo container Certbot   #########################"
   $DOCKER stop Certbot > /dev/null 2>&1 && \
	   $DOCKER rm Certbot > /dev/null 2>&1 && \
	   $DOCKER/bin/docker rmi certbot/certbot:latest > /dev/null 2>&1
}

gerar_pem(){

   echo ""
   echo "### Atualiza o arquivo .PEM   #############################"
   $CAT $PATHLETS/live/$CERTDOMAIN/fullchain.pem $PATHLETS/live/$CERTDOMAIN/privkey.pem > $PATHCERTS/certificado.pem	

}

reiniciar_haproxy(){
   echo ""
   echo "### Reiniciando o HAProxy    ##############################"
   echo ""
   $DOCKER restart HAProxy > /dev/null 2>&1
}



######################################
###   CRIACAO   ######################
if [[ $1 = "-new" ]]; then

   # Verificacao do local de armazenamento
   if [[ -d $PATHLETS && -d $PATHCERTS ]]; then 
      echo ""
      echo "### Diretorio existente   #################################"
   else 
      mkdir -p  $PATHLETS $PATHCERTS
      echo ""
      echo "### Diretorio criado   ####################################"
   exit 0
   fi

   criar_certificado

   remover_container

   gerar_pem

   reiniciar_haproxy

   exit 0
fi


################################################
###   EXPANSAO   ###############################
if [[ $1 = "-exp" ]]; then

   expandir_certificado

   remover_container

   gerar_pem

   reiniciar_haproxy

   exit 0
fi


##################################################
###   RENOCACAO   ################################
if [[ $1 = "-renew" ]]; then

   renovar_certificado

   remover_container

   gerar_pem

   reiniciar_haproxy

   exit 0
fi




