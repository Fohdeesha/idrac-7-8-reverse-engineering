#!/bin/sh
echo "$(date): $1 $2 " >> /tmp/autonic.log
if [ "$2" = "up" ]; then
  /usr/etc/autonic/autonicswitcher.sh 1
else
  /usr/etc/autonic/autonicswitcher.sh 0
fi
