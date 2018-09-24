#!/bin/sh

#FM_STATUS=`/avct/sbin/fmchk clp -d 1 | awk '{print $1}'`
FM_STATUS=$1
CONFIG_FILE=/flash/data0/etc/passwd
TMP_FILE=$(mktemp /tmp/clp_config.XXXXXX)
trap 'rm -f $TMP_FILE' EXIT

if [ $FM_STATUS == "1" ]; then
    sed 's/\/bin\/racadm/\/usr\/bin\/clpd/' $CONFIG_FILE > $TMP_FILE
else
    sed 's/\/usr\/bin\/clpd/\/bin\/racadm/' $CONFIG_FILE > $TMP_FILE
fi
if diff -q $CONFIG_FILE $TMP_FILE > /dev/null
then
    cat $TMP_FILE > $CONFIG_FILE
fi
