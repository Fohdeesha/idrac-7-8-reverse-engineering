#!/bin/sh
# Start the avct_server component
# Startup Dependency: logging
# Startup Dependency: AIM
# Startup Dependency: OSINET
# Startup Dependency: video_drv
# Startup Dependency: usb_drv

RETVAL=0
modulename="/sbin/avct_server"
rootname="avct_server"
FULLFEATURES="true"
version="3.70.2"

#
# full_features () - check for full features configuration
# Note - there is no good way to do this.  A non full features
# configuration (ipmi only) will not include JAVA clients
#
# updates global variable FULLFEATUES
#
full_features() {
	if [ -f "/usr/local/www/software/avctKVM.jar" ] ; then
		return 1;
	fi;

	echo "NOTICE: Not full features configuration - avct_server at minimal configuration"
	FULLFEATURES="false"
	return 0;
}

check_for_driver() {
     if ! lsmod | grep aess_video; then
       source /etc/sysapps_script/I_video_drv.sh
     else
       echo "Driver aess_video already loaded"
     fi
}

start() {
        #full_features

        check_for_driver

	# Create default AIM variables
	# if ! /avct/sbin/aim_config_get_bool vkvm_bool_enabled; then
	#	/avct/sbin/aim_config_set_bool vkvm_bool_enabled true true
	# fi
	# /avct/sbin/aim_config_set_str rp_str_keyboard_encrypt "AES" true
        aim_config_set_str vdisk_str_setup1 01
#
# BITS147341 - Avoid disabling the vMedia port in case VM attach mode is Attach
# and PM has already started
#
#       /avct/sbin/aim_config_set_str vdisk_str_setup2 01
        aim_config_set_str vdisk_str_setup3 01
        aim_config_set_str vdisk_str_setup4 01
        aim_config_set_str vdisk_str_setup5 01
        aim_config_set_bool pm_bool_usb_hub_present true

        # CR BITS240639 - vMedia Only
        # Create the variable for APCP/Websocket receive buffer size
        # in case it does not exist (first start after factory defaults or
        # firmware upgarde from versions < 2.30.30)
        if ! aim_config_get_int rp_int_apcp_socket_recvbufsize ; then
                aim_config_set_int rp_int_apcp_socket_recvbufsize 0 1
                echo "vMedia buffer not initialized, assuming default"
        fi

        /bin/shmwrite -i 2 0 > /dev/null 2>&1
        # Create /tmp/images directory
	if [ ! -e /tmp/images ]; then
	        mkdir /tmp/images
	fi

        if [ "x${1}" = "xskip" ]; then
            exit 0
        fi

	cnt=$(ps -T | grep -c $modulename)

	if [ $cnt -le 1 ]
	then
		#
		# For debug mode, the component must be started in background.
		# If NOT debug mode (default), the component should be started
		# in foreground (it will fork a child and then exit).
		#
		# For debug mode, uncomment the following line and comment out
		# the entire if statement after it
		# $modulename -d [n] &
		if [ $FULLFEATURES = "true" ] ; then
			$modulename
			# JIT-64616, merged from 14G
			wtime=0
			for j in $(seq 0 119); do
				avct_control imginfo > /dev/null 2>&1 \
					&& shmwrite -i 2 1 > /dev/null 2>&1 \
					&& break;
				sleep 1
				wtime=$((wtime + 1))
			done
			if [ $wtime -gt 0 ]; then
				echo "Waited for $wtime second(s) for VMEDIA_READY."
			fi
		else
			# Attempt VM-Only execution of application
			$modulename -i
			cnt=$(ps -T | grep -c $modulename)
			if [ $cnt -le 1 ] ; then
				echo "$modulename not built with VM-Only option"
				$modulename
			fi
		fi
	else
		echo "$modulename already running"
		echo
	fi
	echo "start $rootname version: $version"
	return $RETVAL
}

stop() {
	aim_config_set_bool vkvm_enable_video_capture false
	sleep 2
	killall -9 $rootname
        /bin/shmwrite -i 2 0 > /dev/null 2>&1
}

restart() {
	stop
	start
}

reset() {
    avct_control --id=ALL --value=DEFAULT setcfg
	stop
}

status_at() {
	cnt=$(ps -T | grep -c $modulename)

	if [ $cnt -gt 1 ]
	then
		echo -n "$modulename running"
		echo
	else
		echo -n "$modulename not running"
		echo
	fi
}

version() {
	echo "$rootname version: $version"
}

case "$1" in
start)
	start
	;;
init)
        start "skip"
        ;;
stop)
	stop
	;;
reset)
	reset
	;;
restart)
	restart
	;;
status)
	status_at
	;;
version)
	version
	;;
*)
	echo $"Usage: $0 {start|stop|restart|reset|status|version}"
	exit 1
esac

exit $RETVAL

