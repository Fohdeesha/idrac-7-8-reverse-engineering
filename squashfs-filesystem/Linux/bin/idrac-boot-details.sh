#!/bin/sh

IDRAC_BOOTDETAILS_ENABLE_FLAG="/flash/data0/idrac_bootdetails_enable"
IDRAC_BOOTDETAILS_DISABLE_FLAG="/flash/data0/idrac_bootdetails_disable"
IDRAC_BOOTDETAILS_FILE="/tmp/idrac_boot_details"
IDRAC_FULLY_READY=1
IPMI_READY=2
OSINET_READY=32
MASER_READY=64

case "$1" in
    enable)
        touch $IDRAC_BOOTDETAILS_ENABLE_FLAG
        rm -rf $IDRAC_BOOTDETAILS_DISABLE_FLAG
        exit 0
        ;;
    disable)
        rm -rf $IDRAC_BOOTDETAILS_ENABLE_FLAG
        touch $IDRAC_BOOTDETAILS_DISABLE_FLAG
        exit 0
        ;;
esac

# exit if explicitly disabled
if [ -e $IDRAC_BOOTDETAILS_DISABLE_FLAG ]; then
    exit 0
fi

# enable for xrev
if [ ! -e $IDRAC_BOOTDETAILS_ENABLE_FLAG -a ! "false" = "$(cat /etc/arev.txt)" ]; then
    # exit immediately is not enabled, to minimize impact to the boot progress
    exit 0
fi

# display boot progress details on the console. More impact to the boot progress. The following loop will stop when iDRAC is fully ready
FULL=.
OSINET=.
MASER=.
IPMI=.
DM_READY=0
EVENT_NET_READY=0
IP_READY=0
while [ $DM_READY -eq 0 -o $EVENT_NET_READY -eq 0 -o $FULL = "." -o $IP_READY -eq 0 ]
do
    IDRAC_PROGRESS=$(shmread -s 10 -o 0 -l 1 | tr -d ' ')
    if [ "$IDRAC_PROGRESS" != "$IDRAC_PROGRESS_PREV" ]; then

        if [ $FULL = "." -a $(( 0x$IDRAC_PROGRESS & IDRAC_FULLY_READY )) -eq $IDRAC_FULLY_READY ]; then 
            echo DM Ready: $(cat /proc/uptime | awk '{print $1}')
            DM_READY=1
            echo iDRAC Fully Ready: $(cat /proc/uptime | awk '{print $1}')
            FULL=O
        fi

        if [ $OSINET = "." -a $(( 0x$IDRAC_PROGRESS & OSINET_READY )) -eq $OSINET_READY ]; then 
            echo OSINET Ready: $(cat /proc/uptime | awk '{print $1}')
            OSINET=O
        fi

        if [ $MASER = "." -a $(( 0x$IDRAC_PROGRESS & MASER_READY )) -eq $MASER_READY ]; then 
            echo MASER Ready: $(cat /proc/uptime | awk '{print $1}')
            MASER=O
        fi
        
        if [ $IPMI = "." -a $(( 0x$IDRAC_PROGRESS & IPMI_READY )) -eq $IPMI_READY ]; then 
            echo IPMI Ready: $(cat /proc/uptime | awk '{print $1}')
            IPMI=O
        fi

        echo "Time $(cat /proc/uptime | awk '{print $1}') Full: ($FULL)  MASER: ($MASER)  OSINET: ($OSINET)  IPMI: ($IPMI)" >> $IDRAC_BOOTDETAILS_FILE
        IDRAC_PROGRESS_PREV=$IDRAC_PROGRESS
        continue
    fi
# Calling getDMstatus in a loop has an impact to DM ready, therefore commenting it out
# Will use iDRAC fully ready bit to display DM ready as DM is the last piece before iDRAC fully ready is asserted
#    if [ $DM_READY -eq 0 ] && ! getDMstatus 2>/dev/null | grep -q 'NOT READY' > /dev/null; then
#        DM_READY=1
#        echo DM Ready: $(cat /proc/uptime)
#    fi
    if [ $EVENT_NET_READY -eq 0 -a -e /tmp/EVENT_NETCHANGE_ACTIVE ]; then
        EVENT_NET_READY=1
# We don't need to display EVENT_NET_READY timing (creates confusion to the test teams)
#        echo "EVENT_NETCHANGE_ACTIVE Ready: $(cat /tmp/EVENT_NETCHANGE_ACTIVE)"
    fi
# BITS167007: Wave2-BO:Implenetation to log iDRAC IP ready when the iDRAC is only configured with IPV6 address
# Just grep for inet. This will catch any inet addr or inet6 addr for IPv4 or IPv6 config
    if [ $IP_READY -eq 0 ] && ifconfig bond0 2>/dev/null | grep -q "inet" > /dev/null 2>&1 ; then
        IP_READY=1
        echo "IP Ready: $(cat /proc/uptime | awk '{print $1}')"
    fi

    sleep 1
done

for i in credential-vault.log network.log setup-flash.log 
do 
    mv /tmp/$i /var/log 2>/dev/null ||:
done

dmesg > /var/log/dmesg.log
journalctl -a > /var/log/journal.log
vmstat -s > /var/log/vmstat-s.log

sleep 30

systemd-analyze blame > /var/log/blame.log
systemd-analyze plot > /var/log/plot.svg
vmstat -d > /var/log/vmstat-disk.log

echo
echo BOOT Details for $(get-system-name) | tee /var/log/boot-speed.txt
grep -h BMC_READY /var/log/journal.log* | tee -a /var/log/boot-speed.txt
grep -h Ready /var/log/journal.log* | tee -a /var/log/boot-speed.txt
echo

exit 0
