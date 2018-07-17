#!/bin/bash

DIR_PATH=$(pwd)
CONF_FILES_DIR="conf-files"
CONTAINER_BASE_PATH="/root/fogbow-manager-core"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"

IMAGE_NAME="fogbow/fogbow-manager-core"
CONTAINER_NAME="manager-core"

MANAGER_CONF_FILE=$CONF_FILES_DIR/"manager.conf"
SERVER_PORT_PATTERN="manager_server_port"
MANAGER_PORT=$(grep $SERVER_PORT_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')
CONTAINER_PORT="8080"

echo "Manager server port: $MANAGER_PORT"

INTERCOMPONENT_CONF_FILE=$CONF_FILES_DIR/"intercomponent.conf"
XMPP_PORT_PATTERN="xmpp_server_port"
XMPP_PORT=$(grep $XMPP_PORT_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')
CONTAINER_XMPP_PORT="5327"

echo "Manager xmpp port: $XMPP_PORT"

CONTAINER_DATABASE_PATH_PATTERN="jdbc_database_url"
CONTAINER_DATABASE_PATH=$(grep $CONTAINER_DATABASE_PATH_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')
CONTAINER_DATABASE_DIR=$(dirname $CONTAINER_DATABASE_PATH)

HOST_DATABASE_DIR=$DIR_PATH/"databases"

echo "Mapping container database directory: $CONTAINER_DATABASE_DIR to host directory: $HOST_DATABASE_DIR"

mkdir -p $HOST_DATABASE_DIR

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $MANAGER_PORT:$CONTAINER_PORT \
	-p $XMPP_PORT:$CONTAINER_XMPP_PORT \
	-v $DIR_PATH/$CONF_FILES_DIR:$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILES_DIR \
	-v $HOST_DATABASE_DIR:$CONTAINER_DATABASE_DIR \
	$IMAGE_NAME

