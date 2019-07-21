#!/bin/bash
DIR=$(pwd)
SERVICES_DIR="services"

GENERAL_CONFIGURATIONS=$DIR
PRE_INSTALL_SERVICE=$SERVICES_DIR/"pre-install"
DATABASE_SERVICE_DIR=$SERVICES_DIR/"fogbow-database"
AUTHENTICATION_SERVICE_DIR=$SERVICES_DIR/"authentication-service"
RESOURCE_ALLOCATION_SERVICE_DIR=$SERVICES_DIR/"resource-allocation-service"
XMPP_SERVICE_DIR=$SERVICES_DIR/"xmpp-server"
MEMBERSHIP_SERVICE_DIR=$SERVICES_DIR/"membership-service"
DASHBOARD_SERVICE_DIR=$SERVICES_DIR/"fogbow-gui"
FED_NET_SERVICE_DIR=$SERVICES_DIR/"federated-network-service"
FED_NET_AGENT_DIR=$SERVICES_DIR/"federated-network-agent"

SERVICES_LIST="$GENERAL_CONFIGURATIONS $PRE_INSTALL_SERVICE $DATABASE_SERVICE_DIR $AUTHENTICATION_SERVICE_DIR $RESOURCE_ALLOCATION_SERVICE_DIR $APACHE_SERVICE_DIR $XMPP_SERVICE_DIR $MEMBERSHIP_SERVICE_DIR $DASHBOARD_SERVICE_DIR $FED_NET_SERVICE_DIR $FED_NET_AGENT_DIR"

for service in $SERVICES_LIST; do
	echo ""
	echo "Running $service/env-composer.sh"
	echo ""
	bash $service/"env-composer.sh"
done
