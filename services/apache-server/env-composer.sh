#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
CONF_FILES_DIR_NAME="conf-files"
BASE_DIR="services/apache-server"
BASE_CONFIGURATION_DIR=$BASE_DIR/"shibboleth-environment"
APACHE_CONF_FILES_DIR="apache-confs"

GUI_CONF_DIR="gui-confs"
GUI_CONF_FILE="gui.conf"

# Copying configuration files
echo "Copying services.conf to service directory"
SERVICES_FILE="services.conf"
yes | cp -f $CONF_FILES_DIR/$SERVICES_FILE $BASE_DIR/$SERVICES_FILE
# Copy shared file
SHARED_INFO="shared.info"
yes | cp -f $DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_INFO $BASE_DIR/$SHARED_INFO
echo "Copying gui.conf to service directory"
yes | cp -f $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE $BASE_DIR/$GUI_CONF_FILE

# Moving apache conf files

CONF_FILES_LIST=$(find $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR | grep '.conf' | xargs)

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$BASE_DIR/$conf_file_name
done

# Resolving certification files for https
CERT_CONF_FILE="certificate-files.conf"

CERTIFICATE_FILE="SSL_certificate_file_path"
CERTIFICATE_FILE_PATH=$(grep $CERTIFICATE_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_FILE_NAME=$(basename $CERTIFICATE_FILE_PATH)

CERTIFICATE_KEY_FILE="SSL_certificate_key_file_path"
CERTIFICATE_KEY_FILE_PATH=$(grep $CERTIFICATE_KEY_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_KEY_FILE_NAME=$(basename $CERTIFICATE_KEY_FILE_PATH)

CERTIFICATE_CHAIN_FILE="SSL_certificate_chain_file_path"
CERTIFICATE_CHAIN_FILE_PATH=$(grep $CERTIFICATE_CHAIN_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_CHAIN_FILE_NAME=$(basename $CERTIFICATE_CHAIN_FILE_PATH)

# Fill certificate files in virtual host
VIRTUAL_HOST_FILE="000-default.conf"
yes | cp -f $BASE_DIR/$VIRTUAL_HOST_FILE'.example' $BASE_DIR/$VIRTUAL_HOST_FILE
SSL_DIR="/etc/ssl/private"
CERTS_DIR="/etc/ssl/certs"

CERTIFICATE_PATTERN="SSLCertificateFile"
sed -i "s#$CERTIFICATE_PATTERN.*#$CERTIFICATE_PATTERN $CERTS_DIR/$CERTIFICATE_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_KEY_PATTERN="SSLCertificateKeyFile"
sed -i "s#$CERTIFICATE_KEY_PATTERN.*#$CERTIFICATE_KEY_PATTERN $SSL_DIR/$CERTIFICATE_KEY_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_CHAIN_PATTERN="SSLCertificateChainFile"
sed -i "s#$CERTIFICATE_CHAIN_PATTERN.*#$CERTIFICATE_CHAIN_PATTERN $CERTS_DIR/$CERTIFICATE_CHAIN_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

# Fill redirects and proxy configurations in vhost file

# replace internal-host-ip
HOST_CONF="hosts.conf"
INTERNAL_HOST_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $INTERNAL_HOST_IP_PATTERN $CONF_FILES_DIR/$HOST_CONF | awk -F "=" '{print $2}')

sed -i "s|$INTERNAL_HOST_IP_PATTERN|$INTERNAL_HOST_IP|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace internal-host-name
INTERNAL_HOST_NAME_PATTERN="internal_host_name"
FNS_DOMAIN_NAME_PATTERN="fns_domain_name"
DOMAIN_NAME_CONF_FILE="domain-names.conf"
DOMAIN_NAME=$(grep -w $FNS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')
DOMAIN_BASENAME=$(basename $DOMAIN_NAME)

sed -i "s|$INTERNAL_HOST_NAME_PATTERN|$DOMAIN_BASENAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace certificate files

CRT_FILE_PATTERN="crt_file"
sed -i "s|$CRT_FILE_PATTERN|$CERTIFICATE_FILE_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

KEY_FILE_PATTERN="key_file"
sed -i "s|$KEY_FILE_PATTERN|$CERTIFICATE_KEY_FILE_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

CHAIN_FILE_PATTERN="chain_file"
sed -i "s|$CHAIN_FILE_PATTERN|$CERTIFICATE_CHAIN_FILE_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# Get service ports
GUI_PORT=$(grep ^gui_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
GUI_PORT_PATTERN="gui_port"

FNS_PORT=$(grep ^fns_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
FNS_PORT_PATTERN="fns_port"

AS_PORT=$(grep ^as_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
AS_PORT_PATTERN="as_port"

RAS_PORT=$(grep ^ras_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
RAS_PORT_PATTERN="ras_port"

MS_PORT=$(grep ^ms_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
MS_PORT_PATTERN="ms_port"
#sed -i "s/$MS_PORT_PATTERN\b/$MS_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE

sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $BASE_DIR/$VIRTUAL_HOST_FILE
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $BASE_DIR/$VIRTUAL_HOST_FILE
sed -i "s|$MS_PORT_PATTERN|$MS_PORT|g" $BASE_DIR/$VIRTUAL_HOST_FILE
sed -i "s|$FNS_PORT_PATTERN|$FNS_PORT|g" $BASE_DIR/$VIRTUAL_HOST_FILE
sed -i "s|$GUI_PORT_PATTERN|$GUI_PORT|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# Update documentation file
DOCUMENTATION_FILE="index.html"

sed -i "s|$INTERNAL_HOST_IP_PATTERN|$INTERNAL_HOST_IP|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$INTERNAL_HOST_NAME_PATTERN|$DOMAIN_BASENAME|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$MS_PORT_PATTERN|$MS_PORT|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$FNS_PORT_PATTERN|$FNS_PORT|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$GUI_PORT_PATTERN|$GUI_PORT|g" $BASE_DIR/$DOCUMENTATION_FILE

CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE | awk -F "=" '{print $2}')

# SHIBBOLETH SCENARY
if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
  SHIBBOLETH_CONF_FILE="shibboleth.conf"

  # Fill apache+shibboleth mod 
  SHIBBOLETH_VIRTUAL_HOST_80_FILE="default.conf"
  yes | cp -f $BASE_CONFIGURATION_DIR/$SHIBBOLETH_VIRTUAL_HOST_80_FILE'.example' $BASE_DIR/$SHIBBOLETH_VIRTUAL_HOST_80_FILE
  SHIBBOLETH_VIRTUAL_HOST_443_FILE="shibboleth-sp2.conf"
  yes | cp -f $BASE_CONFIGURATION_DIR/$SHIBBOLETH_VIRTUAL_HOST_443_FILE'.example' $BASE_DIR/$SHIBBOLETH_VIRTUAL_HOST_443_FILE
  SHIBBOLETH_XML_FILE="shibboleth2.xml"
  yes | cp -f $BASE_CONFIGURATION_DIR/$SHIBBOLETH_XML_FILE'.example' $BASE_DIR/$SHIBBOLETH_XML_FILE

  DOMAIN_SERVICE_PROVIDER_PATTERN_CONF_FILE="domain_service_provider"
  DOMAIN_SERVICE_PROVIDER=$(grep $DOMAIN_SERVICE_PROVIDER_PATTERN_CONF_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')

  DISCOVERY_SERVICE_URL_PATTERN_CONF_FILE="discovery_service_url"
  DISCOVERY_SERVICE_URL=$(grep $DISCOVERY_SERVICE_URL_PATTERN_CONF_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')

  DISCOVERY_SERVICE_METADATA_URL_PATTERN_CONF_FILE="discovery_service_metadata_url"
  DISCOVERY_SERVICE_METADATA_URL=$(grep $DISCOVERY_SERVICE_METADATA_URL_PATTERN_CONF_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')

  ## default.conf
  DOMAIN_SERVICE_PROVIDER_PATTERN="_HOSTNAME_"
  sed -i "s#$DOMAIN_SERVICE_PROVIDER_PATTERN#$DOMAIN_SERVICE_PROVIDER#" $BASE_DIR/$SHIBBOLETH_VIRTUAL_HOST_80_FILE

  ## shibboleth-sp2.conf
  sed -i "s#$DOMAIN_SERVICE_PROVIDER_PATTERN#$DOMAIN_SERVICE_PROVIDER#" $BASE_DIR/$SHIBBOLETH_VIRTUAL_HOST_443_FILE

  SHIBBOLETH_AUTHENTICATION_APPLICATION_ADDRESS_PATTERN="_ADDRESS_SHIBBOLETH_AUTH_APPLICATION_"
  SHIBBOLETH_AUTHENTICATION_APPLICATION_ADDRESS_DEFAULT_VALUE="127.0.0.1:9000"
  sed -i "s#$SHIBBOLETH_AUTHENTICATION_APPLICATION_ADDRESS_PATTERN#$SHIBBOLETH_AUTHENTICATION_APPLICATION_ADDRESS_DEFAULT_VALUE#" $BASE_DIR/$SHIBBOLETH_VIRTUAL_HOST_443_FILE

  ## shibboleth2.xml
  sed -i "s#$DOMAIN_SERVICE_PROVIDER_PATTERN#$DOMAIN_SERVICE_PROVIDER#" $BASE_DIR/$SHIBBOLETH_XML_FILE

  DISCOVERY_SERVICE_METADATA_URL_PATTERN="_DS_META_"
  sed -i "s#$DISCOVERY_SERVICE_METADATA_URL_PATTERN#$DISCOVERY_SERVICE_METADATA_URL#" $BASE_DIR/$SHIBBOLETH_XML_FILE
  DISCOVERY_SERVICE_URL_PATTERN="_DS_"
  sed -i "s#$DISCOVERY_SERVICE_URL_PATTERN#$DISCOVERY_SERVICE_URL#" $BASE_DIR/$SHIBBOLETH_XML_FILE

  # Fill apache+shibboleth mod 
  LOG4J_PROPERTIES_FILE="log4j.properties"
  yes | cp -f $BASE_CONFIGURATION_DIR/$LOG4J_PROPERTIES_FILE'.example' $BASE_DIR/$LOG4J_PROPERTIES_FILE

  SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE="shibboleth-authentication-application.conf"
  yes | cp -f $BASE_CONFIGURATION_DIR/$SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE'.example' $BASE_DIR/$SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE

  FOGBOW_GUI_URL_PATTERN_CONF_FILE="dashboard_domain_name"
  FOGBOW_GUI_URL=$(grep $FOGBOW_GUI_URL_PATTERN_CONF_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

  ## Managing keys and certificates
  OPENSSL_INSTALLED_NAME=$(basename `ls /usr/bin/openssl`)
  if [ "$OPENSSL_INSTALLED_NAME" != "openssl" ]; then
    sudo apt-get install -y openssl
  fi

  SHARED_FOLDER_NAME="shared-folder"
  SHARED_FOLDER_DIR=$DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_FOLDER_NAME

  SHIB_RAS_PEM_NAME="rsa_key.pem"
  SHIB_PRIVATE_KEY_NAME="shibboleth_authentication_application_private_key.pem"
  SHIB_PUBLIC_KEY_NAME="shibboleth_authentication_application_public_key.pem"
  openssl genrsa -out $SHARED_FOLDER_DIR/$SHIB_RAS_PEM_NAME 1024
  openssl pkcs8 -topk8 -in $SHARED_FOLDER_DIR/$SHIB_RAS_PEM_NAME -out $SHARED_FOLDER_DIR/$SHIB_PRIVATE_KEY_NAME -nocrypt
  openssl rsa -in $SHARED_FOLDER_DIR/$SHIB_PRIVATE_KEY_NAME -outform PEM -pubout -out $SHARED_FOLDER_DIR/$SHIB_PUBLIC_KEY_NAME

  SHIB_PRIVATE_KEY_PATH=$SHARED_FOLDER_DIR/$SHIB_PRIVATE_KEY_NAME
  yes | cp -f $SHIB_PRIVATE_KEY_PATH $BASE_DIR/$SHIB_PRIVATE_KEY_NAME

  yes | cp -f -r $SHARED_FOLDER_DIR $BASE_DIR/$SHARED_FOLDER_NAME

  ## Service provider certificate
  SERVICE_PROVIDER_CERTIFICATE_FILE="certificate_service_provider_path"
  SERVICE_PROVIDER_CERTIFICATE_FILE_PATH=$(grep $SERVICE_PROVIDER_CERTIFICATE_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')
  SERVICE_PROVIDER_CERTIFICATE_FILE_NAME=$(basename $SERVICE_PROVIDER_CERTIFICATE_FILE_PATH)

  yes | cp -f $SERVICE_PROVIDER_CERTIFICATE_FILE_PATH $BASE_DIR/$SERVICE_PROVIDER_CERTIFICATE_FILE_NAME

  SERVICE_PROVIDER_CERTIFICATE_KEY_FILE="key_service_provider_path"
  SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATH=$(grep $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')
  SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME=$(basename $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATH)

  yes | cp -f $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATH $BASE_DIR/$SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME

  SHARED_FOLDER_INTO_CONTAINER_PATH="/home/ubuntu/"$SHARED_FOLDER_NAME

  SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN="shib_http_port="
  SHIB_HTTP_PORT="9000"
  sed -i "s#$SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN#$SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN$SHIB_HTTP_PORT#" $BASE_DIR/$SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE

  SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN="fogbow_gui_url="
  sed -i "s#$SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN#$SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN$FOGBOW_GUI_URL#" $BASE_DIR/$SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE

  SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN="ship_private_key_path="
  sed -i "s#$SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN#$SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN$SHIB_PRIVATE_KEY_NAME#" $BASE_DIR/$SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE

  SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN="as_public_key_path="
  AS_PUBLIC_KEY_NAME="as_public_key.pem"
  AS_PUBLIC_KEY_DEFAULT_VALUE=$SHARED_FOLDER_INTO_CONTAINER_PATH/$AS_PUBLIC_KEY_NAME
  sed -i "s#$SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN#$SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN$AS_PUBLIC_KEY_DEFAULT_VALUE#" $BASE_DIR/$SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE

  SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN="service_provider_machine_ip="
  SERVICE_PROVIDER_MACHINE_IP=127.0.0.1
  sed -i "s#$SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN#$SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN$SERVICE_PROVIDER_MACHINE_IP#" $BASE_DIR/$SHIBBOLETH_AUTHENTICATION_APPLICATION_PROPERTIES_FILE
fi
