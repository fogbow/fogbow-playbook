#!/bin/bash
CONTAINER_NAME="apache-server"
VIRTUAL_HOST_DIR_PATH="/etc/apache2/sites-available"
ROOT_DIR_PATH="/var/www/html"
INDEX_FILE_NAME="index.html"
VIRTUAL_HOST_FILE_NAME="000-default.conf"
TMP_INDEX_FILE_NAME="index.html.fed"
TMP_VIRTUAL_HOST_FILE_NAME="000-default.conf.fed"

cp $VIRTUAL_HOST_FILE_NAME $TMP_VIRTUAL_HOST_FILE_NAME
cp $INDEX_FILE_NAME $TMP_INDEX_FILE_NAME

ed -s $TMP_VIRTUAL_HOST_FILE_NAME <<!
/ras
.,+t+
-
.,+1s,ras,ms ,g
-
.,+1s,8082,8083
w
q
!

ed -s $TMP_INDEX_FILE_NAME <<!
/8082
-2,+2t+2
-2
s,8082,8083
s,Resource allocation,Membership
w
q
!

sudo docker cp $TMP_VIRTUAL_HOST_FILE_NAME $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_FILE_NAME
sudo docker cp $TMP_INDEX_FILE_NAME $CONTAINER_NAME:$ROOT_DIR_PATH/$INDEX_FILE_NAME

sudo docker exec $CONTAINER_NAME /bin/bash -c "/etc/init.d/apache2 restart"
