insmod /lib/modules/aess_adcsensordrv.ko
rm -rf /dev/aess_adcsensordrv;dmesg | grep /dev/aess_adcsensordrv | cut -c 4- > /tmp/cmd;. /tmp/cmd;rm -f /tmp/cmd
