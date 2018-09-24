#!/bin/sh
set -x

CLR_PS_FILE=/flash/data0/clr_ps.cmd
CCR_AUTOSYNC_FILE=/flash/data0/oem_ps/ccr_autosync_disabled
MASER_DISABLED_FILE=/flash/data0/oem_ps/maserdisabled
CCR_ENABLED_FILE=/flash/data0/oem_ps/ccr_enabled
PART_CONFIG_UPDATE_FILE=/flash/data0/oem_ps/ccr_configuration_state
PART_FW_UPDATE_FILE=/flash/data0/oem_ps/ccr_update_fw_mode
SAVE_NW_CONFIG_FILE=/flash/data0/save_nw.cmd

PART_CONFIG_UPDATE_ON=1
PART_FW_UPDATE_ALWAYS=2

# Create OEM PS folder
mkdir -p /flash/data0/oem_ps

# Clear Persistent Storage per request, i.e. if ${CLR_PS_FILE} exists
if [ -e ${CLR_PS_FILE} ] ; then
  cd /flash/data0
  cp /flash/data0/config/LCD_1 /tmp/
  #save nw files if the file save_nw.cmd is present
  if [ -e ${SAVE_NW_CONFIG_FILE} ] ; then
    cp -r /flash/data0/config/network_config /tmp/
  fi
  # Remove all except OEM Private Storage, rsdsafe
  rm -rf $(ls -a /flash/data0 | grep -v -e oem_ps -e rsdsafe -e persmod)

  # Reset LC Attributes
  rm -rf ${CCR_AUTOSYNC_FILE}					#CSIOR = Enabled
  rm -rf ${MASER_DISABLED_FILE}					#LC = Enabled
  touch ${CCR_ENABLED_FILE}  					#Part replacement = On
  echo $PART_CONFIG_UPDATE_ON > ${PART_CONFIG_UPDATE_FILE} 	#Part configuration update = On
  echo $PART_FW_UPDATE_ALWAYS > ${PART_FW_UPDATE_FILE}		#Part fw update = Always    
  sync
  mkdir /flash/data0/config
  cp /tmp/LCD_1 /flash/data0/config/
  cp -r /tmp/network_config /flash/data0/config/

  #For 13G, CV image is moved to /mmc1 from /flash/data0
  #Deleting .cv.img file from /mmc1; creating a flag to delete CV image
  #when systemd_oem_preinit.sh is executed. 
  touch ${NVRAM_DATA0}/clr_cv_img
  mkdir /flash/data0/cv
fi

