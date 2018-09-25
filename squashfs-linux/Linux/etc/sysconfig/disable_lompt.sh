#!/bin/sh
# should be called only when lom-pt disabled
# Disable unused lom-pt nics
#if grep -q ncsi /sys/class/net/bond0/bonding/slaves ; then
    # nic selection is not shared lom; disable unused nics
#    for dev in $(grep ncsi /proc/net/dev | cut -d":" -f1); do ifconfig $dev down; done;
#else
    # nic selection is shared lom; clear IP address
    for dev in $(grep ncsi /proc/net/dev | cut -d":" -f1); do ifconfig $dev 0.0.0.0; done;
#fi
