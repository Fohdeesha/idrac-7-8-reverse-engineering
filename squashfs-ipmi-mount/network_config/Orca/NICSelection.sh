#!/bin/sh

ifconfig ${DEDICATE_MAC} up
if [ $? -ne 0 ] ; then
    echo "Error - faile to bring up ${DEDICATE_MAC}"
    NEED_RECOVER="yes"
fi

if [ "${NEED_RECOVER}" != "yes" ]; then
ifconfig bond0 up
ifenslave -d bond0 ${DEDICATE_MAC} ncsi0 ncsi1 ncsi2 ncsi3
ifenslave bond0 ${DEDICATE_MAC}
fi

