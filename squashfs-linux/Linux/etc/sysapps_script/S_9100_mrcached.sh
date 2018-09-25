#!/bin/sh
##############################################################################
#
#          Dell Inc. PROPRIETARY INFORMATION
# This software is supplied under the terms of a license agreement or
# nondisclosure agreement with Dell Inc. and may not be copied or disclosed
# except in accordance with the terms of that agreement.
#
# Copyright (c) 2010-2012 Dell Inc. All Rights Reserved.
#
# Linux Startup Init Script
#
##############################################################################

PROGRAM="/usr/sbin/mrcached"
OPTS=""
PROGRAMNAME="`basename ${PROGRAM}`"
OUTLOG="/tmp/mrcached.log"
RETVAL=0
#-----------------------------------------------------------------------------
start()
{
    echo -n "Starting: ${PROGRAMNAME} "
    if [ -n "`pidof ${PROGRAMNAME}`" ]; then
        echo "already running"
        RETVAL=1
    else
        #ulimit -c unlimited
        (${PROGRAM} ${OPTS} 2>&1) >${OUTLOG} &
        sleep 1
        if [ -n "`pidof ${PROGRAMNAME}`" ]; then
           echo "OK"
        else
           echo "failed! check ${OUTLOG}."
           RETVAL=2
        fi
    fi
}
#-----------------------------------------------------------------------------
stop()
{
    echo -n "Stopping: ${PROGRAMNAME} "
    if [ -z "`pidof ${PROGRAMNAME}`" ]; then
        echo "already stopped"
        RETVAL=3
    else
        killall -TERM ${PROGRAMNAME} >/dev/null 2>&1
        sleep 1
        if [ -z "`pidof ${PROGRAMNAME}`" ]; then
           echo "OK"
        else
           echo "failed! check ${OUTLOG}."
           RETVAL=5
        fi
    fi
}
#-----------------------------------------------------------------------------
status()
{
    echo -n "Status: ${PROGRAMNAME} "
    if [ -n "`pidof ${PROGRAMNAME}`" ]; then
        echo "is running"
    else
        echo "is stopped"
        RETVAL=4
    fi
}
#-----------------------------------------------------------------------------
myps()
{
    ps | grep -v grep | grep ${PROGRAMNAME}
    RETVAL=$?
}
#-----------------------------------------------------------------------------
case "$1" in
    start) start ;;
    stop) stop ;;
    restart|reload) stop ; RETVAL=0 ; start ;;
    status) status ;;
    ps) myps ;;
    *) echo "Usage: $0 {start|stop|restart|status|ps}" && exit 1
esac
echo
exit ${RETVAL}
#-----------------------------------------------------------------------------

