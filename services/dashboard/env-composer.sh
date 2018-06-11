#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/dashboard"
CONTAINER_DIR="/root/fogbow-dashboard-core"

# Getting manager and membership ip and port

IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $IP_PATTERN $CONF_FILES_DIR/"hosts.conf" | awk -F "#" '{print $1}' | awk -F "=" '{print $2}')

MANAGER_IP=$INTERNAL_HOST_IP

PORT_PATTERN="server_port"
MANAGER_PORT=$(grep $PORT_PATTERN $CONF_FILES_DIR/"manager.conf" | awk -F "#" '{print $1}' | awk -F "=" '{print $2}')

MEMBERSHIP_IP=$INTERNAL_HOST_IP
MEMBERSHIP_PORT=$(grep $PORT_PATTERN $CONF_FILES_DIR/"membership.conf" | awk -F "#" '{print $1}' | awk -F "=" '{print $2}')

echo "Manager url: $MANAGER_IP:$MANAGER_PORT"
echo "Membership url: $MEMBERSHIP_IP:$MEMBERSHIP_PORT"

MANAGER_AUTH_TYPE=$5
MANAGER_AUTH_ENDPOINT=$6

CONF_FILE_NAME="local_settings.py"

yes | cp -f $BASE_DIR/$CONF_FILE_NAME".example" $BASE_DIR/$CONF_FILE_NAME

sed -i "s#.*FOGBOW_MANAGER_ENDPOINT.*#FOGBOW_MANAGER_ENDPOINT = 'http://$MANAGER_IP:$MANAGER_PORT'#" $BASE_DIR/$CONF_FILE_NAME

sed -i "s#.*FOGBOW_MEMBERSHIP_ENDPOINT.*#FOGBOW_MEMBERSHIP_ENDPOINT = 'http://$MEMBERSHIP_IP:$MEMBERSHIP_PORT'#" $BASE_DIR/$CONF_FILE_NAME

sed -i "s#.*FOGBOW_FEDERATION_AUTH_ENDPOINT.*#FOGBOW_FEDERATION_AUTH_ENDPOINT = '$MANAGER_AUTH_ENDPOINT'#" $BASE_DIR/$CONF_FILE_NAME

if [ "$MANAGER_AUTH_TYPE" == "ldap" ]; then
	sed -i "s#.*FOGBOW_FEDERATION_AUTH_TYPE.*#FOGBOW_FEDERATION_AUTH_TYPE = 'ldap'#" $BASE_DIR/$CONF_FILE_NAME

	PRIVATE_KEY_PATH=$7
	PRIVATE_KEY_NAME=$(basename $PRIVATE_KEY_PATH)
	yes | cp -f $PRIVATE_KEY_PATH $BASE_DIR/$PRIVATE_KEY_NAME
	sed -i "s!.*# PRIVATE_KEY_PATH.*!PRIVATE_KEY_PATH = '$CONTAINER_DIR/$PRIVATE_KEY_NAME'!" $BASE_DIR/$CONF_FILE_NAME

	PUBLIC_KEY_PATH=$8
	PUBLIC_KEY_NAME=$(basename $PUBLIC_KEY_PATH)
	yes | cp -f $PUBLIC_KEY_PATH $BASE_DIR/$PUBLIC_KEY_NAME
	sed -i "s!.*# PUBLIC_KEY_PATH.*!PUBLIC_KEY_PATH = '$CONTAINER_DIR/$PUBLIC_KEY_NAME'!" $BASE_DIR/$CONF_FILE_NAME

	FOGBOW_LDAP_BASE=$9
	sed -i "s!.*# FOGBOW_LDAP_BASE.*!FOGBOW_LDAP_BASE = '$FOGBOW_LDAP_BASE'!" $BASE_DIR/$CONF_FILE_NAME

	FOGBOW_LDAP_ENCRYPT=${10}
	sed -i "s!.*# FOGBOW_LDAP_ENCRYPT.*!FOGBOW_LDAP_ENCRYPT = '$FOGBOW_LDAP_ENCRYPT'!" $BASE_DIR/$CONF_FILE_NAME
fi

