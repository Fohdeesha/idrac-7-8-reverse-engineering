#!/bin/sh
RETVAL=0

srcdir="/etc/default/certs"
destdir="/etc/certs"
is_blade=$(/avct/sbin/aim_config_get_bool platform_bool_is_blade || echo false)

start() {
	if [ "$is_blade" == "false" ]; then
		echo "Not Blade. Not execute."
		exit 1
	fi
	
	if [ ! -f "$destdir/cmcauth.cert" ]; then
		cp $srcdir/cmcauth.cert $destdir/.
		cp $srcdir/cmcauth.key $destdir/.
		chmod 600 $destdir/cmcauth.*
	fi
}

start
