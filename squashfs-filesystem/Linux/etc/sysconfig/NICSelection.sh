#!/bin/sh

# MANUFACTURE_MODE taken care in NetSetThread
NET_MODE=$1
AUTO=$2
nicFail=0
set -e
# Check for HW Arbitration bit for shared LOM
if [ -e /flash/data0/features/dcs ]; then
    hwarbit=1
else
hwarbit=`cat /sys/bus/platform/drivers/ncsi_protocol/ncsi_device_number | xargs | cut -d" " -f13`
fi
if [[ $NET_MODE != 0 ]] && [[ $hwarbit == 1 ]] ; then
    ifconfig eth1 up
    niclst=`/etc/sysconfig/netmode.sh $NET_MODE`
else
    /usr/bin/DedicatedNICControl.sh start
    niclst="eth0"
fi

# remove slave devices
set +e
for i in 1 2 3 4 5 6 7 8 9 10
do
    echo "loop: $i"
    ifconfig bond0 up
    rc=$?
    echo "rc: $rc"
    if [ $rc != 0 ] ; then
        nicFail=1
        sleep 1
    else
        nicFail=0
        break
    fi
done
if [ $nicFail == 1 ] ; then
    echo "Attempted to bring up bond0, it failed returning 1"
    exit 1
fi
if [ $i -gt 1 ] ; then
    echo "Pass $i, fixed ifconfig bond0 up"
fi
set -e

#ifconfig bond0 up
slave_lst=`cat /sys/devices/virtual/net/bond0/bonding/slaves`

echo "slave_lst: ${slave_lst}"

if [ "${slave_lst}" != "" ]; then
    ifenslave -d bond0 ${slave_lst}
fi

# bring up interfaces before attaching slave
if [[ -e /flash/data0/features/platform-modular ]] || [[ ${AUTO} == 1 ]] ; then
    ifconfig eth0 up
fi

echo "niclst: ${niclst}"

set +e

#JIT-100441 IPaddress dropping during osinet reconfig,
#retrying "ifconfig <nic#> up" 3 times to account for timing issue
for i in 1 2 3 4 5 6 7 8 9 10
do
    echo "nic loop: $i"
    for nic in ${niclst}
    do
        ifconfig $nic up
        rc=$?
        echo "rc: $rc"
        if [ $rc != 0 ] ; then
            nicFail=1
            break
        else
            nicFail=0
        fi
    done
    if [ $nicFail == 0 ] ; then
        break
    else
        sleep 1
    fi
done

if [ $nicFail == 1 ] ; then
    echo "Attempted to bring up $nic, it failed returning 1"
    exit 1
fi
if [ $i -gt 1 ] ; then
    echo "Pass $i, fixed ifconfig $nic up"
fi

# CR BITS 240639 - Tuning of the receive buffer of vConsole/vMedia socket to restore Wave3 performance
#It was found through testing that Q-logic, Intel, cards
#all did best with buffer sies of 16k for tcp_rmem and tcp_wmem.
#Emulex cards worked best with buffer size of 8k.
#Broadcom with 28k


# Code revisited for CR BITS240639 - vMedia Only - The value set here will be the value
# set by setsockopt() for the avct server socket. No need to divide desired values by 2

# Allow AIM command to fail in case AIM variables do not exist
#set +e
vmedia_oldbufsize=`aim_config_get_int rp_int_apcp_socket_recvbufsize`
vmedia_bufsize=0
# Variable does not exist, set to defaults (Monolithic DNIC => No need to change)
if [ -z "$vmedia_oldbufsize" ]; then
    vmedia_oldbufsize=0
fi

if [[ $NET_MODE != 0 ]] ; then
    #Using Shared LOM
    # Get from OSINet's aim variable created to work around LOM cards limitations
    #lom_capbuf is the true reported buffer size of LOM card some cards report 0

    lom_capbuf=`aim_config_get_int osinet_int_lom_capbuf`
    if [ -n "$lom_capbuf" ]; then
        echo "$0: LOM Card in use. Receiving capabilies: $lom_capbuf"
        if [[ $lom_capbuf -ge 16384 ]] ; then
            vmedia_bufsize=`expr $lom_capbuf - 2048`
            vmedia_bufsize=`expr $vmedia_bufsize \* 2`
        elif [[ $lom_capbuf -ge 8000 ]] ; then
            vmedia_bufsize=16384
        else
            #Emulex (Some Emulex cards report 0 for buffer some 4k)
            vmedia_bufsize=6144
        fi
    fi
else
    #Using Dedicated NIC
    if [[ -e /flash/data0/features/platform-modular ]] ; then
        #Blade System
        vmedia_bufsize=16384
    fi
        # else Monolithic System, no change from defaults
fi
set -e
# Set new vMedia receive buffer size. If changed, APS will receive the event
# associated with the setting of the variable
if [ $vmedia_oldbufsize != $vmedia_bufsize ]; then
    aim_config_set_int rp_int_apcp_socket_recvbufsize $vmedia_bufsize 1
fi

# really dont think necessary. but copied from older script
sleep 5

# attach slave interfaces
ifenslave bond0 ${niclst}
