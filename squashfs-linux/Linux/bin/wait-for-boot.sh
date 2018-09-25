#!/bin/sh

set -e

#up to 300 seconds?
maxtries=20 

tries=0

while [ $tries -le $maxtries ]
do
    tries=$((tries+1))
    echo "$1: $tries... " >> /tmp/boot_tries
    if [ -f $1 ]; then
         break
    fi
    sleep 1
done

echo
exit 0
