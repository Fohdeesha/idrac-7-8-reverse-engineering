#!/bin/sh
# Bash script launched by the uDEV rule with 2 Arguments.
#       Argument 1: Device letter [a-z]
#       Argument 2: the device number mapped [1-9]
# Based on the argument the below rules will be executed.

set -xv
echo "Add USB config : test start"
USB_FOLDER=/tmp/usbfolder
XML_CONFIG_DIR=/tmp/usbfolder/System_Configuration_XML
TMP_FOLDER=/tmp
index=1
max_size=20000
unmount_dev() {
    	modserxmlfiles=$(ls $TMP_FOLDER/*-config.xml 2> /dev/null | wc -l)
		modserjsonfsize=$(ls $TMP_FOLDER/*-config.json 2> /dev/null | wc -l)
    	normxmlfile=$(ls $TMP_FOLDER/config.xml 2> /dev/null | wc -l)
    	normaljsonfsize=$(ls $TMP_FOLDER/config.json 2> /dev/null | wc -l)
    	cntrxmlfile=$(ls $TMP_FOLDER/control.xml 2> /dev/null | wc -l)
    	resultxmlfile=$(ls $TMP_FOLDER/results.xml 2> /dev/null | wc -l)
# remove the Modul Name or Service tag based XML Files to /tmp
       if [ "$modserxmlfiles" != "0" ]; then
         echo "Module or Service Based XML files Found remove it"
         rm -rf $TMP_FOLDER/*-config.xml
       fi
# remove the Modul Name or Service tag based JSON Files to /tmp
       if [ "$modserjsonfsize" != "0" ]; then
         echo "Module or Service Based JSON files Found remove it"
        rm -rf $TMP_FOLDER/*-config.json
       fi
# remove the Plain or normal XML Files to /tmp
       if [ "$normxmlfile" != "0" ]; then
         echo "Normal XML files Found remove it"
         rm -f $TMP_FOLDER/config.xml
       fi
# remove the Plain or normal JSON Files to /tmp
       if [ "$normaljsonfsize" != "0" ]; then
         echo "Normal JSON files Found remove it"
        rm -f $TMP_FOLDER/config.json
       fi
# remove the control XML Files to /tmp
       if [ "$cntrxmlfile" != "0" ]; then
         echo "Control XML files Found "
         rm -f $TMP_FOLDER/control.xml
      fi
# remove the results XML Files to /tmp
       if [ "$resultxmlfile" != "0" ]; then
         echo "Results XML files Found "
         rm -f $TMP_FOLDER/results.xml
       fi
       umount $USB_FOLDER
#  Add 3 sync to get the device unmounted and flush out any IO Read/Write
# Without adding this the USB Device gets IO Buffer Read Error and State of
# USB register getting marked with SOF Error. Addign 3 sync resolves it.
# NOTE Don;t remove this sync.
       sync
       sync
       sync
       rm -rf $USB_FOLDER
}

validate_xml() {
     USBKEYS=$(
     grep -Hv ^0$ /sys/block/sd*/removable |
     sed s/removable:.*$/device\\/uevent/ |
     xargs grep -H ^DRIVER=sd |
     sed s/device.uevent.*$/size/ |
     xargs grep -Hv ^0$ |
     cut -d / -f 4
     )
     mkdir $USB_FOLDER
     mount -t vfat /dev/$USBKEYS$index $USB_FOLDER -o noexec -o nodev -o nosuid -o sync
     sync
     if [ -d "$USB_FOLDER" ];then
      if [ -d "$XML_CONFIG_DIR" ];then
    	modserxmlfsize=$(du -c $XML_CONFIG_DIR/*-config.xml | grep total | cut -f1)
		modserjsonfsize=$(du -c $XML_CONFIG_DIR/*-config.json | grep total | cut -f1)
    	normalxmlfsize=$(du -c $XML_CONFIG_DIR/config.xml | grep total | cut -f1)
    	normaljsonfsize=$(du -c $XML_CONFIG_DIR/config.json | grep total | cut -f1)
    	cntrlxmlfsize=$(du -c $XML_CONFIG_DIR/control.xml | grep total | cut -f1)
    	resultxmlfsize=$(du -c $XML_CONFIG_DIR/results.xml | grep total | cut -f1)
    	fmaxsize=$(( $modserxmlfsize + $modserjsonfsize + $normalxmlfsize + $normaljsonfsize + $cntrlxmlfsize ))
       echo $fmaxsize
# Copy the Modul Name or Service tag based XML/JSON Files to /tmp
    if [[ "$modserxmlfsize" != "0" && $fmaxsize -le $max_size ]] || [[ "$modserjsonfsize" != "0" && $fmaxsize -le $max_size ]] || [[ "$normxmlfsize" != "0" && $fmaxsize -le $max_size ]] || [[ $normaljsonfsize != 0 && $fmaxsize -le $max_size ]]; then
            echo "Module or Service Based XML/JSON files Found "
            echo "Normal XML/JSON files Found "
            cp --no-dereference $XML_CONFIG_DIR/*-config.xml /tmp/
            cp --no-dereference $XML_CONFIG_DIR/*-config.json /tmp/
            cp --no-dereference $XML_CONFIG_DIR/config.xml /tmp/
            cp --no-dereference $XML_CONFIG_DIR/config.json /tmp/
# Copy the control XML Files to /tmp
            if [[ "$cntrxmlfsize" != "0" && $cntrlxmlfsize -le $max_size ]]; then
                echo "Control XML files Found "
                cp --no-dereference $XML_CONFIG_DIR/control.xml /tmp/
            fi
# Copy the results XML Files to /tmp
            if [[ "$resultxmlfile" != "0" && $resultxmlfsize -le $max_size ]]; then
                echo "Results XML files Found "
                cp --no-dereference $XML_CONFIG_DIR/results.xml /tmp/
            fi
# Launch the XML Import
            xmlconfigagent usb &
            exit 0
       else
	     echo "No Xml files found "
       fi
      fi
     fi
     usbapp_pid=$(pidof usb_app)
     echo $usbapp_pid
     kill -USR1 $usbapp_pid
}
validate_block_dev() {
     USBKEYS=$(
     grep -Hv ^0$ /sys/block/sd*/removable |
     sed s/removable:.*$/device\\/uevent/ |
     xargs grep -H ^DRIVER=sd |
     sed s/device.uevent.*$/size/ |
     xargs grep -Hv ^0$ |
     cut -d / -f 4
     )
     stick=$USBKEYS
     for disk in /sys/block/$USBKEYS/sd* ;do
           echo $disk
     	   found=0
     done
     if [[ $found -eq 0 ]]; then
     	mknod /dev/$USBKEYS$index b 8 1
     fi
     validate_xml
}


case "$1" in
start)
    validate_block_dev
    ;;
stop)
    unmount_dev
    ;;
*)
   echo $"Usage: $0 {start|stop}"
   exit 1
esac

exit $?
exit $RETVAL

