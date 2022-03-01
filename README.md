# SCRIPT de criação de ambiente WEB em container

* Requisito:
	* Instalaçao do Docker
	* Criar os diretórios abaixo. Caso não 
		* /mnt/resources                <- LOCAL ou NFS-Storage
		* /mnt/resources/portainer
		* /mnt/resources/haproxy/certs
		* /mnt/resources/letsencrypt/log
		* /mnt/resources/www/conf
		* /mnt/resources/www/sites-enable/default     <- Incluir os logs
		* /mnt/resources/www/sites-enable/site....    <- Incluir os logs


* Os arquivos deploy_*.sh devem possuir permissão 755.

* Executar o arquivo deploy_portainer.sh em primeiro e depois os outros.

* O arquivo deploy_certbot.sh.	<- Não é requisito inicial de funcionamento


OBs.: Foi disponibilizado arquivos de configuração com ajustes iniciais, altere conforme seus requisitos.
