#!/bin/bash
# This script goal is to generate the Ansible hosts and ansible.cfg files

# Set path variables

SITE_CONF_FILE_NAME="./conf-files/site.conf"
ANSIBLE_FILES_DIR_PATH="./ansible-playbook/basic-site"
ANSIBLE_HOSTS_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"hosts"
ANSIBLE_CFG_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"ansible.cfg"

# Generate content of Ansible hosts file

BASIC_SITE_IP_PATTERN="basic_site_ip"
BASIC_SITE_IP=$(grep $BASIC_SITE_IP_PATTERN $SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN="basic_site_ssh_private_key_file"
BASIC_SITE_PRIVATE_KEY_FILE_PATH=$(grep $BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN $SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

echo "[localhost]" > $ANSIBLE_HOSTS_FILE_PATH
echo "127.0.0.1" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[basic-site-machine]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $BASIC_SITE_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[basic-site-machine:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$BASIC_SITE_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH

# Generate content of Ansible ansible.cfg file

REMOTE_USER_PATTERN="^remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

echo "[defaults]" > $ANSIBLE_CFG_FILE_PATH
echo "inventory = hosts" >> $ANSIBLE_CFG_FILE_PATH
echo "remote_user = $REMOTE_USER" >> $ANSIBLE_CFG_FILE_PATH
echo "host_key_checking = False" >> $ANSIBLE_CFG_FILE_PATH

# Deploy

(cd $ANSIBLE_FILES_DIR_PATH && ansible-playbook deploy.yml)

# House keeping

find . -type f -name "secrets" -exec rm {} \;

chmod -R go-rw conf-files
chmod -R go-rw services
