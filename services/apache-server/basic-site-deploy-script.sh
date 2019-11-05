#!/bin/bash
CURRENT_DIR_PATH=$(pwd)
SERVICE="apache-server"
CERT_CONF_FILE_NAME="certificate-files.conf"
IMAGE_NAME="fogbow/apache-shibboleth-server"
CONF_FILES_DIR_PATH="./conf-files"
SERVICES_CONF_FILE_NAME="services.conf"
CONTAINER_NAME=$SERVICE
CERTS_DIR_PATH="/etc/ssl/certs"
SSL_DIR_PATH="/etc/ssl/private"
VIRTUAL_HOST_DIR_PATH="/etc/apache2/sites-available"
ROOT_DIR_PATH="/var/www/html"
CONF_DIR_PATH="/etc/apache2"
INDEX_FILE_NAME="index.html"
PORTS_FILE_NAME="ports.conf"
VIRTUAL_HOST_FILE_NAME="000-default.conf"
INSECURE_PORT="80"
SECURE_PORT="443"

# Certificate files
## All fogbow environment

CERTIFICATE_FILE_PATTERN="SSL_certificate_file_path"
CERTIFICATE_FILE_PATH=$(grep $CERTIFICATE_FILE_PATTERN $CONF_FILES_DIR_PATH/$CERT_CONF_FILE_NAME | awk -F "=" '{print $2}')
CERTIFICATE_FILE_NAME=$(basename $CERTIFICATE_FILE_PATH)

CERTIFICATE_KEY_FILE_PATTERN="SSL_certificate_key_file_path"
CERTIFICATE_KEY_FILE_PATH=$(grep $CERTIFICATE_KEY_FILE_PATTERN $CONF_FILES_DIR_PATH/$CERT_CONF_FILE_NAME | awk -F "=" '{print $2}')
CERTIFICATE_KEY_FILE_NAME=$(basename $CERTIFICATE_KEY_FILE_PATH)

CERTIFICATE_CHAIN_FILE_PATTERN="SSL_certificate_chain_file_path"
CERTIFICATE_CHAIN_FILE_PATH=$(grep $CERTIFICATE_CHAIN_FILE_PATTERN $CONF_FILES_DIR_PATH/$CERT_CONF_FILE_NAME | awk -F "=" '{print $2}')
CERTIFICATE_CHAIN_FILE_NAME=$(basename $CERTIFICATE_CHAIN_FILE_PATH)

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $CONF_FILES_DIR_PATH/$SERVICES_CONF_FILE_NAME | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $SECURE_PORT:$SECURE_PORT \
	-p $INSECURE_PORT:$INSECURE_PORT \
	-v $CURRENT_DIR_PATH/$CERTIFICATE_FILE_NAME:$CERTS_DIR_PATH/$CERTIFICATE_FILE_NAME \
	-v $CURRENT_DIR_PATH/$CERTIFICATE_KEY_FILE_NAME:$SSL_DIR_PATH/$CERTIFICATE_KEY_FILE_NAME \
	-v $CURRENT_DIR_PATH/$CERTIFICATE_CHAIN_FILE_NAME:$CERTS_DIR_PATH/$CERTIFICATE_CHAIN_FILE_NAME \
	$IMAGE_NAME:$TAG

sudo docker cp $VIRTUAL_HOST_FILE_NAME $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_FILE_NAME
sudo docker cp $INDEX_FILE_NAME $CONTAINER_NAME:$ROOT_DIR_PATH
sudo docker cp $PORTS_FILE_NAME $CONTAINER_NAME:$CONF_DIR_PATH

ENABLE_MODULES_SCRIPT="basic-site-enable-modules"
sudo chmod +x $ENABLE_MODULES_SCRIPT
sudo docker cp $ENABLE_MODULES_SCRIPT $CONTAINER_NAME:/$ENABLE_MODULES_SCRIPT
sudo docker exec $CONTAINER_NAME /$ENABLE_MODULES_SCRIPT
sudo docker exec $CONTAINER_NAME /bin/bash -c "rm /$ENABLE_MODULES_SCRIPT"