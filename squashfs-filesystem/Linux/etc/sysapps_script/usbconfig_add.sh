#!/bin/sh

#adding xmlconfigagent
	mkdir /tmp/usbfolder
        sleep 2 
        mount /dev/sda /tmp/usbfolder
        sync; sync 
        cp /tmp/usbfolder/idracconfig/*.xml /tmp
        sleep 2
        /usr/bin/xmlconfigagent usb      
