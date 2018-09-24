#!/bin/sh
FILENAME="/etc/fw_ver"
if [ -f $FILENAME ]
then
	export APPWEBDATE=`sed -e '1,3d' $FILENAME`
else
	echo " $FILENAME does not exist."
	export APPWEBDATE=`date +%y%m%d%H%M%S`
fi
echo "APPWEBDATE="$APPWEBDATE
cd /usr/local/etc/appweb/ 
export LD_LIBRARY_PATH=/usr/local/lib/appweb:/lib
export SFCC_CLIENT=SfcbLocal
#export AVCT_HTTP_TO_HTTPS_DISABLED=1
#
FILENAME2="/etc/appweb/appweb.conf"
if [ -f $FILENAME2 ]
then
	echo "appweb.conf being loaded from: "$FILENAME2
	/usr/local/bin/appweb -r /usr/local/lib/appweb -f ../../../../etc/appweb/appweb.conf  > /dev/null 2>&1 
else
	echo "Default appweb.conf file being used (/usr/local/lib/appweb/appweb.conf)."
	/usr/local/bin/appweb -r /usr/local/lib/appweb -f ../../etc/appweb/appweb.conf  > /dev/null 2>&1
fi
