#!/bin/sh

#adding xmlconfigagent
        rm /tmp/control.xml
        cp /tmp/results.xml /tmp/usbfolder/idracconfig
        sleep 2
        umount /tmp/usbfolder
        sync; sync 
        rm -rf /tmp/usbfolder
