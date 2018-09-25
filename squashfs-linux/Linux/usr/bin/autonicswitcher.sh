#!/bin/sh
linkstatus=0
if [ -z "$1" ] ; then
    linkstatus=1
else
    linkstatus=$1
fi
/usr/bin/aim_function_execute 1 netAutoNICSwitcher 1 ${linkstatus}
