#!/bin/sh

WSMANSUBS=/flash/data0/wsman_subscriptions
SFCBIND=/var/lib/sfcb/registration/repository/root/interop

RM="/bin/rm -rf"

echo "Deleting subscriptions ..."

# check wsman subscription folder exists
if [ -e ${WSMANSUBS} ]; then
	echo "subscriptions folder found..."
        ${RM} ${WSMANSUBS}
	${RM} ${SFCBIND}/cim_indication*
fi
        
