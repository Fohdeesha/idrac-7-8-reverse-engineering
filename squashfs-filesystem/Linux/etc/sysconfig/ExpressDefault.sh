#!/bin/sh

ifconfig ${NCSI_MAC} up
if [ $? -ne 0 ] ; then
    echo "Error - faile to bring up ${NCSI_MAC}"
    NEED_RECOVER="yes"
fi

if [ "${NEED_RECOVER}" != "yes" ]; then
if [ $dcs_type -eq 8 ]; then
   ifconfig ${NCSI_MAC_DCS} up
fi
ifconfig bond0 up
ifconfig ncsi0 up
ifenslave -d bond0 ${DEDICATE_MAC} ncsi0 ncsi1 ncsi2 ncsi3
ifenslave bond0 ncsi0
fi

