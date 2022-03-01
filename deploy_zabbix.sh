#!/usr/bin/env bash

DOCKER=`which docker`
MKDIR=`which mkdir`

###CONTAINERS
COMPANY="NOME"
NCZBXS="Zabbix_Server"
NCZBXF="Zabbix_Frontend"
NCZBXJ="Zabbix_Java_Gateway"
NCZBXW="Zabbix_Web_Service"
NCZBXST="Zabbix_SNMP_Trap"

###PACOTES
PCZBXS="zabbix/zabbix-server-mysql:latest"
PCZBXF="zabbix/zabbix-web-nginx-mysql:latest"
PCZBXJ="zabbix/zabbix-java-gateway:latest"
PCZBXW="zabbix/zabbix-web-service:latest"
PCZBXST="zabbix/zabbix-snmptraps:latest"

### NET
CTDRI="bridge"
CTSUB="192.168.254.0/24"
CTRAN="192.168.254.0/24"
CTGAT="192.168.254.1"
CTNET="zabbix-net"


#VARIAVEIS
TIMEZONE="America/Sao_Paulo"
RESTART="unless-stopped"
HOMEZBX="/home/CONTAINER/zabbix"
PATHSNMPTRAP="$HOMEZBX/snmptraps"
PATHMIBS="$HOMEZBX/mibs"
IPZBX="<IP_ZBX_SERVER>"
MYLAN="<LAN/CIDR>"


###DATABASE
DBSERVER="<IP_DB_SERVER>"
DBDATABASE="zabbix"
DBUSER="zabbix"
DBPASS="<PASS>"



echo ""
if [[ -d $HOMEZBX ]]; then
   echo "Diretorios existentes."
   else
      $MKDIR -p $HOMEZBX $PATHSNMPTRAP $PATHMIBS
      echo "Diretorios criados."
fi



echo ""
echo "### REMOVENDO CONTAINERS"
### REMOVE CONTAINERS AND IMAGES
$DOCKER stop $NCZBXS && \
        $DOCKER stop $NCZBXF && \
        $DOCKER stop $NCZBXJ && \
        $DOCKER stop $NCZBXW &&\
        $DOCKER stop $NCZBXST &&\
        $DOCKER rm $NCZBXS && \
        $DOCKER rm $NCZBXF && \
        $DOCKER rm $NCZBXJ && \
        $DOCKER rm $NCZBXW && \
        $DOCKER rm $NCZBXST && \
        $DOCKER network rm $CTNET
        #$DOCKER rmi $PCZBXS && \
        #$DOCKER rmi $PCZBXF && \
        #$DOCKER rmi $PCZBXJ && \
        #$DOCKER rmi $PCZBXW && \
        #$DOCKER rmi $PCZBXST && \

#$DOCKER system prune --all --volumes --force


echo ""
echo "### CRIANDO CONTAINERS"
### CREATE NETWORK
$DOCKER network create \
    --driver=$CTDRI \
    --subnet=$CTSUB \
    --ip-range=$CTRAN \
    --gateway=$CTGAT \
    $CTNET

### CREATE ZABBIX SNMPTRAP
$DOCKER run --name $NCZBXST -t \
    -e TZ=$TIMEZONE \
    -v $PATHSNMPTRAP:/var/lib/zabbix/snmptraps:rw \
    -v $PATHMIBS:/usr/share/snmp/mibs:ro \
    --restart $RESTART \
    --network=$CTNET \
    -p 162:1162/udp \
    -d $PCZBXST


### CREATE ZABBIX JAVA GATEWAY
$DOCKER run --name $NCZBXJ -t \
    -e TZ=$TIMEZONE \
    --restart $RESTART \
    --network=$CTNET \
    -p 10052:10052 \
    -d $PCZBXJ

### CREATE ZABBIX WEB SERVICE
$DOCKER run --name $NCZBXW -t \
    -e ZBX_ALLOWEDIP=$MYLAN,$CTSUB \
    -e TZ=$TIMEZONE \
    --cap-add=SYS_ADMIN \
    --restart $RESTART \
    --network=$CTNET \
    -p 10053:10053 \
    -d $PCZBXW

### CREATE ZABBIX SERVER
$DOCKER run --name $NCZBXS -t \
    -e DB_SERVER_HOST=$DBSERVER \
    -e MYSQL_DATABASE=$DBDATABASE \
    -e MYSQL_USER=$DBUSER \
    -e MYSQL_PASSWORD=$DBPASS \
    -e ZBX_JAVAGATEWAY_ENABLE="true" \
    -e ZBX_ENABLE_SNMP_TRAPS="true" \
    -e ZBX_CACHESIZE="256M" \
    -e ZBX_STARTPOLLERS="40" \
    -e ZBX_STARTPOLLERSUNREACHABLE="40" \
    -e ZBX_MAXHOUSEKEEPERDELETE="5000" \
    -e ZBX_STARTDBSYNCERS="4" \
    -e ZBX_HISTORYCACHESIZE="32M" \
    -e ZBX_TRENDCACHESIZE="4M" \
    -e ZBX_VALUECACHESIZE="16M" \
    -e ZBX_STARTPINGERS="20" \
    -e ZBX_STARTDISCOVERERS="20" \
    -e ZBX_TIMEOUT="30" \
    -e ZBX_STARTREPORTWRITERS="3" \
    -e ZBX_WEBSERVICEURL="http://$IPZBX:10053/report" \
    -e TZ=$TIMEZONE \
    --volumes-from $NCZBXST \
    --restart $RESTART \
    --network=$CTNET \
    -p 10051:10051 \
    -d $PCZBXS


### CREATE ZABBIX FRONTEND
$DOCKER run --name $NCZBXF -t \
    -e ZBX_SERVER_NAME=$COMPANY \
    -e ZBX_SERVER_HOST=$NCZBXS \
    -e DB_SERVER_HOST=$DBSERVER \
    -e MYSQL_DATABASE=$DBDATABASE \
    -e MYSQL_USER=$DBUSER \
    -e MYSQL_PASSWORD=$DBPASS \
    -e PHP_TZ=$TIMEZONE \
    -e TZ=$TIMEZONE \
    --restart $RESTART \
    --network=$CTNET \
    -p 8080:8080 \
    -d $PCZBXF




