#! /bin/sh
DEFAULT_CERT_FILE="/usr/share/discovery/client.pem"
NEW_DEFAULT_CERT_FILE="/flash/data0/cv/client.pem"

CERT_FILE="/flash/data0/oem_ps/STAG_client.pem"
NEW_CERT_FILE="/flash/data0/cv/STAG_client.pem"

CERT_FILE_FACTORY="/flash/data0/oem_ps/STAG_client_factory.pem"
NEW_CERT_FILE_FACTORY="/flash/data0/cv/STAG_client_factory.pem"

SIGNED_CERT_FILE="/flash/data0/oem_ps/CUSCLNT.pem"
NEW_SIGNED_CERT_FILE="/flash/data0/cv/CUSCLNT.pem"

CA_PKY_FILE="/flash/data0/oem_ps/CUSSRVPB.pem"
NEW_CA_PKY_FILE="/flash/data0/cv/CUSSRVPB.pem"

IDRAC_DISCOVERY_STATUS_FILE="/tmp/idrac_discovery_status"
STATUS=

# hey, logic on this one is different than all the rest, be aware.
if [ ! -e ${NEW_DEFAULT_CERT_FILE} ]
then
	echo "cp ${DEFAULT_CERT_FILE} ${NEW_DEFAULT_CERT_FILE}">>${IDRAC_DISCOVERY_STATUS_FILE}
	cp ${DEFAULT_CERT_FILE} ${NEW_DEFAULT_CERT_FILE}
fi

if [ -e ${CERT_FILE} ]
then
	echo "mv -f ${CERT_FILE} ${NEW_CERT_FILE}">>${IDRAC_DISCOVERY_STATUS_FILE}
	mv -f ${CERT_FILE} ${NEW_CERT_FILE}
fi

if [ -e ${CERT_FILE_FACTORY} ]
then
	echo "mv -f ${CERT_FILE_FACTORY} ${NEW_CERT_FILE_FACTORY}">>${IDRAC_DISCOVERY_STATUS_FILE}
	mv -f ${CERT_FILE_FACTORY} ${NEW_CERT_FILE_FACTORY}
fi

if [ -e ${SIGNED_CERT_FILE} ]
then		
	echo "mv -f ${SIGNED_CERT_FILE} ${NEW_SIGNED_CERT_FILE}">>${IDRAC_DISCOVERY_STATUS_FILE}
	mv -f ${SIGNED_CERT_FILE} ${NEW_SIGNED_CERT_FILE}
fi

if [ -e ${CA_PKY_FILE} ]
then
	echo "mv -f ${CA_PKY_FILE} ${NEW_CA_PKY_FILE}">>${IDRAC_DISCOVERY_STATUS_FILE}
	mv -f ${CA_PKY_FILE} ${NEW_CA_PKY_FILE}
fi

if [ "x${1}" != "xinit" ]; then
    /bin/idrac_discovery &
else
    echo "idrac_discovery - preinit option used for systemd"
fi
