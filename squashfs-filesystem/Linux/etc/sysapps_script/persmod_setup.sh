#!/bin/sh
# sets up the personality module files
# if they exist on the PM partition (mas026), copy them into the working
# directory in /tmp

set -x

PM_DIR=/tmp/persmod
PM_PTN=/tmp/pmmount
PM_SECUPD=/mnt/scratchpad/mas026
FLAG_DIR=/flash/data0/oem_ps
PERSMOD_DIR=/flash/data0/persmod
FWVERFILE=/etc/fw_ver
PM_INFO=/flash/data0/oem_ps/pm_info
cfglib_files="cfgfld.txt gencfgfld.txt altdefaults.txt iDRACnet.delta"
therm_files="ThermalConfig.txt"
lcd_tkover_files="lcd_bootup.bmp lcdoem.conf"
power_files="poweroem.conf"
re_files="reoem.conf"
lc_files="lcoem.conf"
alert_files="alertoem.conf"
ipmi_files="ipmioem.conf"
oem_fru_files="InitFRUInfo"
xml_config_files="pm_idrac_config.xml oem_id_configuration.xml"
text_files="idrac_supp_sensor_event.txt"
extra_dir="extra"
table_override_files="IO_fl.bin IS_fl.bin IO_api.bin NVRAM_SDR00.dat"
# EXIT_CODE : Allocated Exit codes 221 to 255 for this File.
EXIT_CODE=0
SHASTA_CHECK=/tmp/shasta
source /etc/sysapps_script/pm_logger.sh

mount_pm_ptn()
{
   res=`mount|grep ${PM_PTN}`
   if [ -z "$res" ] ; then
      if [ ! -d ${PM_PTN} ] ; then
         mkdir ${PM_PTN}
      fi
         /etc/sysapps_script/mountMaser.sh /mmc1/mas026.img ${PM_PTN} /tmp/mountresult
   fi
}

unmount_pm_ptn()
{
   sync
   umount ${PM_PTN}
   rmdir ${PM_PTN}
}

add_gzip_compression_for_idrac_images()
{
   echo "Compressing images to gz format"
   for images in $PM_DIR/idrac/*.png $PM_DIR/idrac/*.ico $PM_DIR/idrac/*.gif $PM_DIR/idrac/*.jpg
   do
      # echo $images
      gzip -f $images
   done
}

preserve_pm()
{
   # The api below is to preserve idrac settings after customer PM is installed

   if [ -f /flash/data0/persmod/iDRACnet.delta ] ;  then
      debug_log "PM Install : Updating iDRACnet.delta to iDRACnet.default and iDRACnet.conf"
      echo "PM Install : Updating iDRACnet.delta to iDRACnet.default and iDRACnet.conf"
      source /etc/sysapps_script/pm_network_delta_update.sh /flash/data0/config/network_config/iDRACnet.default /flash/data0/persmod/iDRACnet.delta
      source /etc/sysapps_script/pm_network_delta_update.sh /flash/data0/config/network_config/iDRACnet.conf /flash/data0/persmod/iDRACnet.delta
   fi

   if [ -f /flash/data0/persmod/lcdoem.conf ] ; then
      debug_log "PM Install : Updating LCD settings"
      # EXIT_CODE : Allocated Exit codes 33 to 70 for this File.
      source /etc/sysapps_script/pm_lcd_update.sh
      ret_val=$?
      if [ $ret_val -ne 0 ] ; then
         EXIT_CODE=$ret_val
      fi
   fi

   if [ -f /flash/data0/persmod/poweroem.conf ] ; then
      debug_log "PM Install : Updating Power settings"
      # EXIT_CODE : Allocated Exit codes 71 to 100 for this File.
      source /etc/sysapps_script/pm_power_update.sh
      ret_val=$?
      if [ $ret_val -ne 0 ] ; then
         EXIT_CODE=$ret_val
      fi
   fi

   if [ -f /flash/data0/persmod/reoem.conf ] ; then
      debug_log "PM Install : Updating Provisioning server settings"
      # EXIT_CODE : Allocated Exit codes 101 to 130 for this File.
      source /etc/sysapps_script/pm_re_update.sh
      ret_val=$?
      if [ $ret_val -ne 0 ] ; then
         EXIT_CODE=$ret_val
      fi
   fi

   if [ -f /flash/data0/persmod/lcoem.conf ] ; then
      debug_log "PM Install : Updating LC settings"
      # EXIT_CODE : Allocated Exit codes 131 to 160 for this File.
      source /etc/sysapps_script/pm_lc_update.sh
      ret_val=$?
      if [ $ret_val -ne 0 ] ; then
         EXIT_CODE=$ret_val
      fi
   fi

   if [ -f /flash/data0/persmod/alertoem.conf ] ; then
      debug_log "PM Install : Updating OEMIPV4 , OEMPEF, OEMAlertCommunityString settings"
      # EXIT_CODE : Allocated Exit codes 161 to 190 for this File.
      source /etc/sysapps_script/pm_alert_update.sh
      ret_val=$?
      if [ $ret_val -ne 0 ] ; then
         EXIT_CODE=$ret_val
      fi
   fi

   if [ -f /flash/data0/persmod/ipmioem.conf ] ; then
      debug_log "PM Install : Updating OEMIpmiOverLanEnable, OEMVflashEnable , OEMFrontPanelEnable settings"
      # EXIT_CODE : Allocated Exit codes 191 to 220 for this File.
      source /etc/sysapps_script/pm_ipmi_update.sh
      ret_val=$?
      if [ $ret_val -ne 0 ] ; then
         EXIT_CODE=$ret_val
      fi
   fi

   #adding xmlconfigagent
   if [ -f ${FLAG_DIR}/pm_info ] ; then
      debug_log "PM Install : Adding xmlconfigagent"
      source /etc/sysapps_script/xmlconfig.sh
   fi
}

# called on bootup, pm files should have been installed to mas026 already
start_pm()
{
   mount_pm_ptn
   # if files exist, copy to working directory
   if [ -e ${PM_PTN}/pm ] ; then
      if [ ! -e ${PM_DIR} ] ; then
         mkdir ${PM_DIR}
      fi
      
      #Hooks for factory installation procedure
      if [ ! -f ${FLAG_DIR}/pm_info ] ; then
         echo "PM update : Started" > ${PM_DEBUG_LOG}
         echo "fffffffffffffffffffffffffffffffe" > ${FLAG_DIR}/pm_update_available
         cp -a ${PM_PTN}/pm/pm_info ${FLAG_DIR}/
         install_pm
         check_for_errors $EXIT_CODE
         mount_pm_ptn
      else
         if [ -f ${PM_PTN}/pm/pm_info ] ; then
            dd if=${PM_PTN}/pm/pm_info bs=1 count=2 skip=0 of=/tmp/nver
            dd if=${FLAG_DIR}/pm_info bs=1 count=2 skip=0 of=/tmp/over
            cmp -s /tmp/nver /tmp/over
            if [ $? -ne 0 ] ; then
               echo "PM update : Started" > ${PM_DEBUG_LOG}
               echo "fffffffffffffffffffffffffffffffe" > ${FLAG_DIR}/pm_update_available
               cp -a ${PM_PTN}/pm/pm_info ${FLAG_DIR}/
               install_pm
               check_for_errors $EXIT_CODE
               mount_pm_ptn   
            else
               echo "No changes found in PM"
            fi
            rm -f /tmp/nver /tmp/over
         else
            echo "Continuing"
         fi 
      fi

      cp -a ${PM_PTN}/pm/idrac ${PM_PTN}/pm/Diags ${PM_PTN}/pm/uscre ${PM_DIR}
      # cfglib files arent needed in this dir since they live in /flash/data0,
      # remove to free memory
      for file in $cfglib_files $therm_files $lcd_tkover_files $power_files $re_files $lc_files $alert_files $ipmi_files $oem_fru_files $xml_config_files $text_files $extra_dir ; do
         rm -rf ${PM_DIR}/idrac/${file}
      done
      
      if [ -f /flash/data0/persmod/idrac_supp_error.sh ] ; then
         source /flash/data0/persmod/idrac_supp_error.sh
      fi
      f=`dd if=${FLAG_DIR}/pm_info bs=1 count=1 skip=2 2> /dev/null | hexdump -e '1/1 "%d" "\n"'`

      #Compress iDRAC images to gz format.Added from 13g Wave-3 to fix defect BITS171981
      add_gzip_compression_for_idrac_images 

      # api from avocent to do the gui stuff
      if [ $f -ne 3 ] ; then
         echo "Debranding System"
         source /etc/sysapps_script/setPersonality.sh /usr/local/www/debranded
      else
         echo "Branding System"
         source /etc/sysapps_script/setPersonality.sh ${PM_DIR}/idrac
      fi
   fi

   # BITS232575 and BITS232612 - reload PM iDRAC settings after customer LCWipe
   if [ -f ${FLAG_DIR}/pm_lcwipe_reload ] ; then
      preserve_pm
      echo "PM iDRAC settings are preserved after LCWipe"
      rm -f ${FLAG_DIR}/pm_lcwipe_reload
   fi

   rm -f /tmp/pminstall
   if [ -f ${PERSMOD_DIR}/pm_install_inprogress ] ; then
		rm -f ${PERSMOD_DIR}/pm_install_inprogress
   fi
   # hook for further install after reboot. unused for now
   unmount_pm_ptn
}

# called after pm zipfile has been downloaded and extracted to mas026 
# by verify_maser.sh
# runs before the reboot, if pmptn is set, it assumes mas026 is mounted
# to that path. otherwise, mas026 will be mounted and used
install_pm()
{
   debug_log "PM Install : Started"
   if [ -z "$pmptn" ] ; then
      if [ -f /tmp/pmsecupd ] ; then
         pmptn=${PM_SECUPD}
      else
         mount_pm_ptn
         pmptn=${PM_PTN}
         need_unmount=1
      fi
   fi

   # cfglib files need to be stored in spi flash to be immediately available
   # on bootup.  the idrac will need to have a racresetcfg, and a reboot
   # performed to fully install PM
   rm -rf ${PERSMOD_DIR}
   mkdir ${PERSMOD_DIR}
   touch ${PERSMOD_DIR}/pm_install_inprogress


   for file in $cfglib_files $therm_files $lcd_tkover_files $power_files $re_files $lc_files $alert_files $ipmi_files $oem_fru_files $xml_config_files $text_files; do
      cp -f ${pmptn}/pm/idrac/${file} ${PERSMOD_DIR}
   done

   # process extra payload
   if [ -d ${pmptn}/pm/idrac/${extra_dir} ] ; then
      if [ ! -d ${PM_DIR}/extrapayload ] ; then
         mkdir -p ${PM_DIR}/extrapayload
      fi
      /usr/bin/unzip ${pmptn}/pm/idrac/${extra_dir}/payload.zip -d ${PM_DIR}/extrapayload

      # install payloads in the extra dir
      for file in ${PM_DIR}/extrapayload/*.sh ; do
         debug_log "PM Install : Executing $file for extra payload"
         chmod +x $file
         $file ${PM_DIR}/extrapayload
      done

      rm -rf ${PM_DIR}/extrapayload
   fi

   debug_log "PM Install : Copied ${pmptn}/pm/idrac/ to ${PERSMOD_DIR}"
   # Invalidate the cached system ID so the entire feature/platform cache will be recreated during boot
   echo "features/platform cache cleanup request" > /flash/data0/features/system-id
   
   # this link will get updated after the reboot
   rm -f /flash/data0/BMC_Data/ThermalConfig.txt
   if [ "$need_unmount" = "1" ] ; then
      unmount_pm_ptn
   fi
   
   f=`dd if=$PM_INFO bs=1 count=1 skip=35 2> /dev/null | hexdump  -e '1/1 "%d" "\n"'`
   if [ $f -eq 1 ] ; then
      if [ -f /flash/data0/persmod/altdefaults.txt ] ; then
         rm -f /flash/data0/config/altdefaults.txt;
         ln -sf /flash/data0/persmod/altdefaults.txt /flash/data0/config/altdefaults.txt;
         # The below workaround to be removed when racresetcfg works
         source /etc/sysapps_script/pm_preserve_settings.sh
         debug_log "PM Install : Updated iDRAC config lib files"
         #Wait for config lib to finish checksum calculation
         sleep 15
      fi

      preserve_pm
   fi

   for file in $table_override_files; do
      if [ -f /flash/data0/persmod/${file} ]; then
         rm -f /flash/data0/BMC_Data/${file}
         ln -sf /flash/data0/persmod/${file} /flash/data0/BMC_Data/${file}
      fi
   done
   
   #Backup Restore Supported 13G onwards. For 12G the file will not exist. 
   if [ -e $SHASTA_CHECK ]; then
      #initiate backup
      debug_log "PM Install : Executing PM Backup and Restore!"
      /etc/sysapps_script/pm_backup_restore.sh -b
      if [ $? -eq 0 ] ; then
         debug_log "PM Install : PM Backup and Restore Completed!" 
         exec_ipmi_cmd "IPMICmd 20 30 0 d0 0 15 10 0 0 0 10 0 0 0 10 0 0 0 0 0 0 0 0 0 0 0" 221
      else
         debug_log "PM Install : PM Backup and Restore Failed!" 
      fi
   fi
}


# convenience api for wiping PM. dev use only
uninstall_pm()
{
   IPMI1="IPMICmd 0x20 0x30 0x00 0xA2 0x14"
   IPMI2="0x81 0x00"
   RET1=`IPMICmd 0x20 0x30 0x00 0xA2 0x00 0x00 0x00 0x00 0x00 0x00`
   BYTE1=`echo $RET1 | cut -c 38-42`
   BYTE2=`echo $RET1 | cut -c 43-47`
   FULL_CMD=$IPMI1" "$BYTE1" "$BYTE2" "$IPMI2
   echo "FULL_CMD : $FULL_CMD"
   $FULL_CMD
   sleep 5
   shutdown -r
}

reset_thermalconfig()
{
   id=`/etc/default/ipmi/getsysid`
   if [ -d /tmp/pd0/ipmi/${id} ] ; then \
      ln -sf /tmp/pd0/ipmi/${id}/ThermalConfig.txt /flash/data0/BMC_Data/ThermalConfig.txt
   else
      ln -sf /etc/default/ipmi/default/ThermalConfig.txt /flash/data0/BMC_Data/ThermalConfig.txt
   fi
}

secure_update()
{
   echo "fffffffffffffffffffffffffffffffe" > ${FLAG_DIR}/pm_update_available
   cp -a ${PM_SECUPD}/pm/pm_info ${FLAG_DIR}/
   touch /tmp/pmsecupd
   debug_log "PM update : Started"
   install_pm ${PM_SECUPD}
   check_for_errors $EXIT_CODE
}


case "$1" in
   start)
      start_pm
   ;;
   
   secupd)
      secure_update
   ;;

   install)
      pmptn=$2
      install_pm
      check_for_errors $EXIT_CODE
   ;;

   uninstall)
      uninstall_pm
   ;;
   *)
   ;;
esac

return $EXIT_CODE 
