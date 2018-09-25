#!/bin/sh
# CLP Script
set -x

start() {
   if [ -e /tmp/sfcbLocalSocket ] ; then
        chmod 666 /tmp/sfcbLocalSocket
   fi
   if [ ! -e /var/run/clp.db3 ] ; then
        cp /etc/default/clp/clp.db3 /var/run
        chmod 777 /var/run/clp.db3
   fi
   if [ ! -e /var/run/clpsvc.db3 ] ; then
        cp /etc/default/clp/clpsvc.db3 /var/run
        chmod 777 /var/run/clpsvc.db3
   fi
}

reset() {
   rm -rf /var/run/clp.db3
   rm -rf /var/run/clpsvc.db3
}

case "$1" in
   start)
      start
      ;;
   reset)
      reset
      ;;
esac

exit 0
