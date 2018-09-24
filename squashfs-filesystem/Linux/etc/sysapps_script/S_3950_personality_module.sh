#!/bin/sh

/etc/sysapps_script/persmod_setup.sh start 2> /tmp/persmod_startup.log
touch /tmp/pmStartUpComplete
