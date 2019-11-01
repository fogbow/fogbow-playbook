#!/bin/bash
SERVICE="fogbow-gui"
CONF_FILE_NAME="gui.conf"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_CONF_FILE_NAME="services.conf"
SITE_CONF_FILE_NAME="site.conf"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy gui.conf
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
## Copy shared info
yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME

# Create and edit api.config.js
API_CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME | awk -F "=" '{print $2}')

yes | cp -f $BASE_DIR_PATH/$AUTH_TYPE_CLASS"-"$API_CONF_FILE_NAME $BASE_DIR_PATH/$API_CONF_FILE_NAME

PROVIDER_ID_PATTERN="provider_id"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

# Setting endpoints

sed -i "s#.*\<as\>:.*#	as: 'https://$PROVIDER_ID/as',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*ras:.*#	ras: 'https://$PROVIDER_ID/ras',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*fns:.*#	fns: 'https://$PROVIDER_ID/fns',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*ms:.*#	ms: 'https://$PROVIDER_ID/ms',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*local:.*#	local: '$PROVIDER_ID',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME

# Setting FNS implementations (if any)
FNS_SERVICE_NAMES_PATTERN="fns_service_names"
FNS_SERVICE_NAMES=$(grep $FNS_SERVICE_NAMES_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME | awk -F "=" '{print $2}')

sed -i "s#.*fnsServiceNames.*#	fnsServiceNames: [$FNS_SERVICE_NAMES],#" $BASE_DIR_PATH/$API_CONF_FILE_NAME

RECONFIGURATION_BASE_DIR_PATH="services/reconfiguration/conf-files"
mkdir -p $RECONFIGURATION_BASE_DIR_PATH

# Setting Shibboleth conf (if applied)
if [ $AUTH_TYPE_CLASS == "shibboleth" ]; then
    SHIB_CONF_FILE_NAME="shibboleth.conf"
    TEMPLATE_SHIB_CONF_FILE_PATH=$CONF_FILE_TEMPLATE_DIR_PATH/$SHIB_CONF_FILE_NAME
    SHIB_CONF_DIR_PATH="services/apache-server/shibboleth-environment"

    # Edit api.config.js
    DOMAIN_SERVICE_PROVIDER_NAME_PATTERN="domain_service_provider"
    SERVICE_PROVIDER_DOMAIN_NAME=$(grep $DOMAIN_SERVICE_PROVIDER_NAME_PATTERN $TEMPLATE_SHIB_CONF_FILE_PATH | awk -F "=" '{print $2}')
    sed -i "s#.*\<remoteCredentialsUrl\>:.*#remoteCredentialsUrl: 'https://$SERVICE_PROVIDER_DOMAIN_NAME',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME

    # Copy general files to reconfiguration folder
    ## Copy shibboleth.conf
    yes | cp -f $TEMPLATE_SHIB_CONF_FILE_PATH $RECONFIGURATION_BASE_DIR_PATH/$SHIB_CONF_FILE_NAME
    ## Copy shared info
    yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $RECONFIGURATION_BASE_DIR_PATH/$SHARED_INFO_FILE_NAME
    ## Copy services file
    yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $RECONFIGURATION_BASE_DIR_PATH/$SERVICES_CONF_FILE_NAME

    # Setup apache info for reconfiguration

    ## Fill apache+shibboleth mod
    SHIB_VIRTUAL_HOST_80_FILE_NAME="default.conf"
    yes | cp -f $SHIB_CONF_DIR_PATH/$SHIB_VIRTUAL_HOST_80_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$SHIB_VIRTUAL_HOST_80_FILE_NAME
    SHIB_VIRTUAL_HOST_443_FILE_NAME="shibboleth-sp2.conf"
    yes | cp -f $SHIB_CONF_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME
    SHIB_XML_FILE_NAME="shibboleth2.xml"
    yes | cp -f $SHIB_CONF_DIR_PATH/$SHIB_XML_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$SHIB_XML_FILE_NAME
    ATTRIBUTE_MAP_XML_FILE_NAME="attribute-map.xml"
    yes | cp -f $SHIB_CONF_DIR_PATH/$ATTRIBUTE_MAP_XML_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$ATTRIBUTE_MAP_XML_FILE_NAME
    ATTRIBUTE_POLICY_XML_FILE_NAME="attribute-policy.xml"
    yes | cp -f $SHIB_CONF_DIR_PATH/$ATTRIBUTE_POLICY_XML_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$ATTRIBUTE_POLICY_XML_FILE_NAME
    INDEX_SECURE_HTML_FILE_NAME="index-secure.html"
    yes | cp -f $SHIB_CONF_DIR_PATH/$INDEX_SECURE_HTML_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$INDEX_SECURE_HTML_FILE_NAME

    DOMAIN_SERVICE_PROVIDER_PATTERN="domain_service_provider"
    DOMAIN_SERVICE_PROVIDER=$(grep $DOMAIN_SERVICE_PROVIDER_PATTERN $TEMPLATE_SHIB_CONF_FILE_PATH | awk -F "=" '{print $2}')

    DISCOVERY_SERVICE_URL_PATTERN="discovery_service_url"
    DISCOVERY_SERVICE_URL=$(grep $DISCOVERY_SERVICE_URL_PATTERN $TEMPLATE_SHIB_CONF_FILE_PATH | awk -F "=" '{print $2}')

    DISCOVERY_SERVICE_METADATA_URL_PATTERN="discovery_service_metadata_url"
    DISCOVERY_SERVICE_METADATA_URL=$(grep $DISCOVERY_SERVICE_METADATA_URL_PATTERN $TEMPLATE_SHIB_CONF_FILE_PATH | awk -F "=" '{print $2}')

    ## default.conf
    HOSTNAME_PATTERN="_HOSTNAME_"
    sed -i "s#$HOSTNAME_PATTERN#$DOMAIN_SERVICE_PROVIDER#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_VIRTUAL_HOST_80_FILE_NAME

    ## shibboleth-sp2.conf
    sed -i "s#$HOSTNAME_PATTERN#$DOMAIN_SERVICE_PROVIDER#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME

    SHIB_AUTHENTICATION_APPLICATION_ADDRESS_PATTERN="_ADDRESS_SHIBBOLETH_AUTH_APPLICATION_"
    SHIB_AUTHENTICATION_APPLICATION_ADDRESS_DEFAULT_VALUE="127.0.0.1:9000"
    sed -i "s#$SHIB_AUTHENTICATION_APPLICATION_ADDRESS_PATTERN#$SHIB_AUTHENTICATION_APPLICATION_ADDRESS_DEFAULT_VALUE#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME

    ## shibboleth2.xml
    sed -i "s#$HOSTNAME_PATTERN#$DOMAIN_SERVICE_PROVIDER#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_XML_FILE_NAME

    DS_META_PATTERN="_DS_META_"
    sed -i "s#$DS_META_PATTERN#$DISCOVERY_SERVICE_METADATA_URL#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_XML_FILE_NAME
    DS_PATTERN="_DS_"
    sed -i "s#$DS_PATTERN#$DISCOVERY_SERVICE_URL#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_XML_FILE_NAME

    ## Fill apache+shibboleth mod
    LOG4J_PROPERTIES_FILE_NAME="log4j.properties"
    yes | cp -f $SHIB_CONF_DIR_PATH/$LOG4J_PROPERTIES_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$LOG4J_PROPERTIES_FILE_NAME

    SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME="shibboleth-authentication-application.conf"
    yes | cp -f $SHIB_CONF_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME'.example' $RECONFIGURATION_BASE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME

    SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN="fogbow_gui_url="
    FOGBOW_GUI_URL="https://"$PROVIDER_ID/
    sed -i "s#$SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN.*#$SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN$FOGBOW_GUI_URL#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME

    SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN="shib_http_port="
    SHIB_HTTP_PORT="9000"
    sed -i "s#$SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN.*#$SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN$SHIB_HTTP_PORT#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME

    SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN="service_provider_machine_ip="
    SERVICE_PROVIDER_MACHINE_IP=127.0.0.1
    sed -i "s#$SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN.*#$SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN$SERVICE_PROVIDER_MACHINE_IP#" $RECONFIGURATION_BASE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME

    ## Managing keys and certificates

    SERVICE_PROVIDER_CERTIFICATE_FILE_NAME="service_provider_certificate.crt"
    SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME="service_provider_certificate.key"

    SERVICE_PROVIDER_CERTIFICATE_FILE_PATTERN="certificate_service_provider_path"
    SERVICE_PROVIDER_CERTIFICATE_FILE_PATH=$(grep $SERVICE_PROVIDER_CERTIFICATE_FILE_PATTERN $TEMPLATE_SHIB_CONF_FILE_PATH | awk -F "=" '{print $2}')

    yes | cp -f $SERVICE_PROVIDER_CERTIFICATE_FILE_PATH $RECONFIGURATION_BASE_DIR_PATH/$SERVICE_PROVIDER_CERTIFICATE_FILE_NAME

    SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATTERN="key_service_provider_path"
    SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATH=$(grep $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATTERN $TEMPLATE_SHIB_CONF_FILE_PATH | awk -F "=" '{print $2}')

    yes | cp -f $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATH $RECONFIGURATION_BASE_DIR_PATH/$SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME

    # Generate shib app key pair
    SHIB_RSA_PEM_FILE_NAME="rsa_key_shibboleth.pem"
    SHIB_PRIVATE_KEY_FILE_NAME="shibboleth-app.pri"
    SHIB_PUBLIC_KEY_FILE_NAME="shibboleth-app.pub"

    openssl genrsa -out $RECONFIGURATION_BASE_DIR_PATH/$SHIB_RSA_PEM_FILE_NAME 1024
    openssl pkcs8 -topk8 -in $RECONFIGURATION_BASE_DIR_PATH/$SHIB_RSA_PEM_FILE_NAME -out $RECONFIGURATION_BASE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME -nocrypt
    openssl rsa -in $RECONFIGURATION_BASE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME -outform PEM -pubout -out $RECONFIGURATION_BASE_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME
    chmod 600 $RECONFIGURATION_BASE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME

    rm $RECONFIGURATION_BASE_DIR_PATH/$SHIB_RSA_PEM_FILE_NAME
fi
