#!/bin/sh
#
# Init file for AppWeb server.  Argument 1= {start|stop|restart|reset}
#
RETVAL=0
#
CONFIG_FILE=/var/run/appweb.conf
TEMPLATE_CONFIG_FILE=/usr/local/etc/appweb/appweb.conf.template
APPWEB=/usr/local/bin/appweb

DEFUALT_HTTP_PORT=80
TMP_TEMPLATE_FILE=/var/run/appweb.conf.template
TMP_TEMPLATE_FILE_1=/var/run/appweb.conf.template_1

#BITS256336-- Nessus Scan tool reports the RC4 is weak & vulnerable
CIPHER_AUTO_NEGOTIATE=ALL:!ADH:!EXPORT56:!RC4:!IDEA:!CBC:!3DES:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL
CIPHER_128BIT_OR_HIGHER=ALL:!ADH:HIGH:MEDIUM:!RC4:!IDEA:!CBC:!3DES:!eNULL:@STRENGTH
#AES128 and SEED are 128 bit strength & are enabled if ALL is appended at end
CIPHER_168BIT_OR_HIGHER=ALL:!ADH:HIGH:!AES128:!SEED:!RC4:!IDEA:!CBC:!3DES:!CAMELLIA128:!eNULL:@STRENGTH
CIPHER_256BIT_OR_HIGHER=ALL:!ADH:HIGH:!AES128:!SEED:!RC4:!IDEA:!CBC:!3DES:!CAMELLIA128:!eNULL:@STRENGTH

#RESTUI-716:TLSV1, TLSV1.1 Configurable
TLS_PROTOCOL_SUITE="ALL -SSLV2 -SSLV3"
TLSV1_ABOVE="$TLS_PROTOCOL_SUITE"
TLSV1_1_ABOVE="$TLSV1_ABOVE -TLSV1"
TLSV1_2_ABOVE="$TLSV1_1_ABOVE -TLSv1.1"


#
export AVCT_SERVICE_MANAGER_CONFIG=/usr/local/etc/serviceman.conf
#
if [ $GUI_DEFAULT_CONFIG ]
then
	unset AIM_WEB_ENABLED
	unset AIM_HTTP_TIMEOUT
	unset AIM_HTTP_PORT
	unset AIM_HTTPS_PORT
	unset GUI_FIRMWARE_UPDATE_TIMEOUT_SECONDS
	unset GUI_FIRMWARE_REBOOT_WAIT_SEC
	unset GUI_KVM_PLUGIN_TYPE
	unset AIM_SSL_ENCRYPTION_ENABLED
	unset SSL_PROTOCOL_SUITE_ENABLED
else
	AIM_WEB_ENABLED=`/avct/sbin/aim_config_get_bool  gui_bool_gui_enabled`
	AIM_HTTP_TIMEOUT=`/avct/sbin/aim_config_get_int gui_int_session_timeout`
	AIM_HTTP_PORT=`/avct/sbin/aim_config_get_int   gui_int_http_port`
	AIM_HTTPS_PORT=`/avct/sbin/aim_config_get_int   gui_int_https_port`
    GUI_FIRMWARE_UPDATE_TIMEOUT_SECONDS=`/avct/sbin/aim_config_get_int  gui_firmware_update_timeout_seconds`
	GUI_FIRMWARE_REBOOT_WAIT_SEC=`/avct/sbin/aim_config_get_int  gui_firmware_reboot_wait_seconds`
	GUI_KVM_PLUGIN_TYPE=`/avct/sbin/aim_config_get_int  gui_kvm_plugin_type`
	GUI_TITLE_BAR=`/avct/sbin/aim_config_get_str gui_str_title_bar`
	GUI_TITLE_BAR_CUSTOM=`/avct/sbin/aim_config_get_str gui_str_title_bar_custom`
	GUI_TITLE_BAR_NUM=`/avct/sbin/aim_config_get_int gui_int_title_bar_num`
	#AIM_SSL_ENCRYPTION_ENABLED=`/avct/sbin/aim_config_get_bool  pm_bool_ssl_encryption_enabled`
	AIM_SSL_ENCRYPTION_ENABLED=`/usr/bin/readcfg -g16393 -f7 |cut -d'=' -f2`
	SSL_PROTOCOL_SUITE_ENABLED=`/usr/bin/readcfg -g16393 -f9 |cut -d'=' -f2`
	CUSTOM_CIPHER_SUITE=`/usr/bin/readcfg -g16393 -f12 |cut -d'=' -f2`
	#JIT-101221 escaping the delimiter / due to sed copy command
	CUSTOM_CIPHER_SUITE="$(echo $CUSTOM_CIPHER_SUITE | sed 's@\/@\\/@g')"
fi
# check if the length of string is zero
if [ -z "$AIM_WEB_ENABLED" ]
then
	echo "Private Storage Erased"
	AIM_WEB_ENABLED=1
	/avct/sbin/aim_config_set_bool  gui_bool_gui_enabled 1 1
	/avct/sbin/aim_config_set_int  gui_kvm_plugin_type 0 1

else
	echo "Configuration Preserved"
	if [ -z "$GUI_KVM_PLUGIN_TYPE" ]
	then
        /avct/sbin/aim_config_set_int  gui_kvm_plugin_type 1 1
	fi	
fi

if [ -z "$AIM_HTTP_TIMEOUT" ]
then
	AIM_HTTP_TIMEOUT=1800
	/avct/sbin/aim_config_set_int  gui_int_session_timeout 1800 1
fi
if [ -z "$AIM_HTTP_PORT" ]
then
	AIM_HTTP_PORT=80
	/avct/sbin/aim_config_set_int  gui_int_http_port 80 1
fi
if [ -z "$AIM_HTTPS_PORT" ]
then
	AIM_HTTPS_PORT=443
	/avct/sbin/aim_config_set_int  gui_int_https_port 443 1
fi
if [ -z "$GUI_FIRMWARE_UPDATE_TIMEOUT_SECONDS" ]
then
	/avct/sbin/aim_config_set_int  gui_firmware_update_timeout_seconds 600 1
fi
if [ -z "$GUI_FIRMWARE_REBOOT_WAIT_SEC" ]
then
	/avct/sbin/aim_config_set_int  gui_firmware_reboot_wait_seconds 5 1
fi
#if [ -z "$GUI_KVM_PLUGIN_TYPE" ]
#then
#	/avct/sbin/aim_config_set_int  gui_kvm_plugin_type 1 1
#fi
if [ -z "$GUI_TITLE_BAR" ]
then
	/avct/sbin/aim_config_set_str  gui_str_title_bar "" 1
fi
if [ -z "$GUI_TITLE_BAR_CUSTOM" ]
then
	/avct/sbin/aim_config_set_str  gui_str_title_bar_custom "" 1
fi
if [ -z "$GUI_TITLE_BAR_NUM" ]
then
	/avct/sbin/aim_config_set_int  gui_int_title_bar_num 0 1
fi

#RESTUI716:TLSProtocol is configurable based on DM attribute TLSProtocol
#ValueMap: 0-TLSV1&Above,1-TLSV1.1&Above,2-TLSV1.2&Above
if [ $SSL_PROTOCOL_SUITE_ENABLED -eq 0 ]; then
	SSL_PROTOCOL_SUITE=$TLSV1_ABOVE
elif [ $SSL_PROTOCOL_SUITE_ENABLED -eq 1 ]; then
	SSL_PROTOCOL_SUITE=$TLSV1_1_ABOVE
elif [ $SSL_PROTOCOL_SUITE_ENABLED -eq 2 ]; then
	SSL_PROTOCOL_SUITE=$TLSV1_2_ABOVE
else
	#default Protocol Suite
	echo "ERROR:DM Value out-of range"
	SSL_PROTOCOL_SUITE=$TLSV1_1_ABOVE
fi

### SSL_CIPHER_SUITES ###
# http://httpd.apache.org/docs/2.0/mod/mod_ssl.html
# !ADH - disable all ciphers using Anonymous Diffie-Hellman key exchange
# HIGH - Start with the "high" cipher suites
# MEDIUM - all ciphers with 128 bit encryption
# !eNULL - Disable null encryption
# @STRENGTH - Sort the remaining cipher suites by their encryption key length
if [ -z "$AIM_SSL_ENCRYPTION_ENABLED" ]; then
	#default auto-negotiation
	SSL_CIPHER_SUITES=$CIPHER_AUTO_NEGOTIATE:$CUSTOM_CIPHER_SUITE
else
	if [ $AIM_SSL_ENCRYPTION_ENABLED -eq 1 ]; then
		SSL_CIPHER_SUITES=$CIPHER_128BIT_OR_HIGHER:$CUSTOM_CIPHER_SUITE
	elif [ $AIM_SSL_ENCRYPTION_ENABLED -eq 2 ]; then
		SSL_CIPHER_SUITES=$CIPHER_168BIT_OR_HIGHER:$CUSTOM_CIPHER_SUITE
	elif [ $AIM_SSL_ENCRYPTION_ENABLED -eq 3 ]; then
		SSL_CIPHER_SUITES=$CIPHER_256BIT_OR_HIGHER:$CUSTOM_CIPHER_SUITE
	else
		#default auto-negotiation
		SSL_CIPHER_SUITES=$CIPHER_AUTO_NEGOTIATE:$CUSTOM_CIPHER_SUITE
	fi	
fi


create_new_config() {
	if [ ! -f $TEMPLATE_CONFIG_FILE ]
	then
		echo "Missing file: $TEMPLATE_CONFIG_FILE"
		exit 1
	fi

	cp -f $TEMPLATE_CONFIG_FILE $TMP_TEMPLATE_FILE
	#Hardcode HTTP port 80 for CMC internal channel(ethX.4003)
	if [ "$AIM_HTTP_PORT" != "80" ]; then 
	    CMC_IF_NAME=`ifconfig -a | awk '/^eth.\.4003/ {print $1}'`
	    if [ -n "$CMC_IF_NAME" ]; then
		CMC_IF_ADDR=`ifconfig $CMC_IF_NAME | grep 'inet addr:' | awk '{print $2}' | cut -d ':' -f2`
		if [ -n "$CMC_IF_ADDR" ]; then
			sed -e '/AIM_HTTP_PORT/{x;/./b;x;h;a\Listen ${CMC_IF_ADDR}:80' -e '}' $TEMPLATE_CONFIG_FILE > $TMP_TEMPLATE_FILE_1
			sed -e "s/\${CMC_IF_ADDR}/$CMC_IF_ADDR/g" $TMP_TEMPLATE_FILE_1 > $TMP_TEMPLATE_FILE
			rm -f $TMP_TEMPLATE_FILE_1
		fi
	    fi
	fi
	
	echo "Creating config file."
	echo "# created `date`" > $CONFIG_FILE
	sed -e "s/\${AIM_WEB_ENABLED}/$AIM_WEB_ENABLED/g" \
		-e "s/\${AIM_HTTP_TIMEOUT}/$AIM_HTTP_TIMEOUT/g" \
		-e "s/\${AIM_HTTP_PORT}/$AIM_HTTP_PORT/g" \
		-e "s/\${AIM_HTTPS_PORT}/$AIM_HTTPS_PORT/g" \
		-e "s/\${SSL_CIPHER_SUITES}/$SSL_CIPHER_SUITES/g" \
		-e "s/\${SSL_PROTOCOL_SUITE}/$SSL_PROTOCOL_SUITE/g" \
		$TMP_TEMPLATE_FILE >> $CONFIG_FILE
	rm -f $TMP_TEMPLATE_FILE
}

start() {
	create_new_config
	export AVCT_SERVICE_MANAGER_CONFIG=/usr/local/etc/serviceman.conf
#	$BIN_PATH 2>&1 > /dev/null &
	if [ ! -e /flash/data0/redfish_subscriptions/subscriptions.json ];
	then
		mkdir /flash/data0/redfish_subscriptions;
		touch /flash/data0/redfish_subscriptions/subscriptions.json;
		echo "{}" >/flash/data0/redfish_subscriptions/subscriptions.json;
	fi

	FILENAME="/etc/fw_ver"
	if [ -f $FILENAME ]
	then
		export APPWEBDATE=`sed -e '1,5d' -e '7,$d' $FILENAME`
	else
		echo " $FILENAME does not exist."
		export APPWEBDATE=`date +%y%m%d%H%M%S`
	fi
	
	echo "APPWEBDATE="$APPWEBDATE
	cd /usr/local/etc/appweb/  #APPU
	export LD_LIBRARY_PATH=/usr/local/lib/appweb:/lib:/usr/local/bin
	export SFCC_CLIENT=SfcbLocal
	#export AVCT_HTTP_TO_HTTPS_DISABLED=1
	#export AVCT_CSRF_PROTECTION_DISABLED=1
	export CMC_IF_NAME=`ifconfig -a | awk '/^eth.\.4003/ {print $1}'`

	#Create the Personality module JSOn if PM is installed..	
	# TBD: Can be optimized
	PM_FILE_INSTALL_CHECKER=/usr/local/etc/appweb/personality/res_en_1.txt
	if [ -f "$PM_FILE_INSTALL_CHECKER" ]; then
		#create All PM JSON Files.
		echo "Personality Module is installed on system, Creating Resource files in JSON format....."
		mkdir -p /tmp/pm
		/usr/bin/jsonresfilecreator
		
		FILES1=/tmp/pm/*json.gz
		FILES2=/usr/local/www/locale/*json.gz
		for src_file in $FILES1
		do
        		  filename1=$(basename $src_file)
		          substring1=${filename1:7:2}
		       	  for tgt_file in $FILES2
        		  do
                		filename2=$(basename $tgt_file)
		                substring2=${filename2:7:2}
        		        if [ "$substring1"  ==  "$substring2" ];
                		then
					if [ -f $src_file ]
					then
						if [ -f $tgt_file ]
						then
        	                			umount $tgt_file
        	                			mount --bind $src_file $tgt_file
        	                		else
        	                			echo "tgt file not present"	
        	                		fi
        	                	else
        	                		echo "src file not present"
	                        	fi
	        	        fi
		         done
		done
	else
		echo "PM is not installed on this machine"
	fi

    if [ "$AIM_WEB_ENABLED" = "false" ] 
    then
        echo "Web enabled=$AIM_WEB_ENABLED.  Exiting S_7600_appweb.sh"
        exit 0
    fi

	echo "appweb.conf being loaded from: "$CONFIG_FILE
        if [ -e /flash/data0/features/fips.txt ]
        then
            export SECURITY_MODULE=1
            # FIPS mode, point to openssl fips capable libraries
            export LD_LIBRARY_PATH=/usr/fips:$LD_LIBRARY_PATH
        fi
        LD_PRELOAD=/usr/lib/libfipsint.so.0.0.0  exec $APPWEB --config $CONFIG_FILE
}

#
#
case "$1" in
	start)
		start
		;;
	reset)
		rm -rf ${CONFIG_FILE}
		/avct/sbin/aim_config_set_bool gui_bool_gui_enabled 1 1
		/avct/sbin/aim_config_set_int  gui_int_session_timeout 1800 1
		/avct/sbin/aim_config_set_int  gui_int_http_port 80 1
		/avct/sbin/aim_config_set_int  gui_int_https_port 443 1
		/avct/sbin/aim_config_set_int  gui_kvm_plugin_type 0 1
		/avct/sbin/aim_config_set_bool  pm_bool_ssl_encryption_enabled 0 1
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|reset}"
		RETVAL=1
esac
exit $RETVAL
