#!/bin/sh
XML_DIR=/flash/data0/persmod

#adding xmlconfigagent
	if [ -f ${XML_DIR}/pm_idrac_config.xml ] ; then      
		echo "Branding System - XML Config Agent"
                if [ -f /flash/data0/oem_ps/pm_rstd ] ; then 
                      sleep 50
                fi
                cp /flash/data0/persmod/pm_idrac_config.xml /tmp
                xmlconfigagent pm
	fi
