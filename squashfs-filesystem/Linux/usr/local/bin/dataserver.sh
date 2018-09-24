#!/bin/sh
export CALLER=gui
export DATA_SERVER_PORT=8195
export AVCT_DEF_PROP_FILE=/usr/local/etc/appweb/default.properties
export AVCT_MAP_PROP_FILE=/usr/local/etc/appweb/map.properties
#export AVCT_DATASERVER_DEBUG=/tmp/dataserver.log
/usr/local/bin/guiDataServer  
