#!/bin/bash
SITE_CONF_FILE_NAME="./conf-files/site.conf"
SECRETS_FILE_PATH="./conf-files/secrets"

REMOTE_USER_PATTERN="remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

VPN_PASSWORD_KEY="vpn_password"
VPN_PASSWORD=$(grep $VPN_PASSWORD_KEY $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

STRONGSWAN_INSTALLATION_SCRIPT="strongswan-installation"
sudo bash $STRONGSWAN_INSTALLATION_SCRIPT $VPN_PASSWORD

# key to provide access from basic-site-machine to vanilla-agent-machine
AGENT_HOST_PUBLIC_KEY=$(cat vanilla-agent-id_rsa.pub)

AUTHORIZED_KEYS_FILE_PATH=/"home"/$REMOTE_USER/".ssh"/"authorized_keys"
grep "$AGENT_HOST_PUBLIC_KEY" $AUTHORIZED_KEYS_FILE_PATH
if [ "$?" -ne "0" ]; then
	echo "$AGENT_HOST_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
fi