#!/bin/sh 
# sets up the persistent thermal configuation file using the personality module

PM_DIR=/flash/data0/persmod
PM_FILE=/flash/data0/persmod/ThermalConfig.txt

help_msg()
{
	echo "$0 <option> <filename> <force>"
	echo "<option>"
	echo "help      this message"
	echo "install   install <filename> as persistent thermal configuration file"
	echo "restore   restore default persistent thermal configuration file"
	echo "reset     reset IPMI firmware"
	echo "force     overwrite existing ThermalConfig.txt file in OM area"
	echo "."
}

copy_config_file()
{
	conf_file=$1
	if [ $# -eq 2 ] ; then
		if [ $2 = "force" ] ; then
			force=1
		else
			force=0
		fi
	else
		force=0
	fi

 	if [ -e $PM_FILE ] ; then
		echo "Thermal Config File $PM_FILE Already exists!"
		if [ $force -eq 0 ] ; then
			echo "Force option not specified - Exiting!"
			exit
		else
			echo "Force option specified, continuing..."
		fi
	fi
        if [ -d $PM_DIR ] ; then
		echo "Directory $PM_DIR Exists!"
        else
		echo "Directory $PM_DIR does not exist, creating..."
		mkdir $PM_DIR
		echo "Directory $PM_DIR Created!"
        fi
	if [ -e $conf_file ] ; then
                echo "Copying file [ $conf_file ] to PM area"
        	cp $1 $PM_FILE
        	echo "Thermal File $conf_file copied to $PM_FILE"
        else
        	echo "File $conf_file does not exist."
		exit
	fi
        if [ -e $PM_FILE ] ; then
		echo "Thermal Config File $conf_file Copied Successfully!"
	fi
}

# hook to install any files on startup
setup_cfglib()
{
	if [ -e $PM_FILE ] ; then
			# echo "$PM_FILE Exists!"
			id=`/etc/default/ipmi/getsysid`
			# echo "id: $id"
			ThermalFileVer=`grep TEMPLATE_REVISION_NUM /flash/data0/persmod/ThermalConfig.txt | sed 's/.*\([X,x]\)\([0-9][0-9]\).*/\2/' `
			if [ -d /tmp/pd0/ipmi/${id} ] ; then
				DRACThermalFileVer=`grep TEMPLATE_REVISION_NUM /tmp/pd0/ipmi/${id}/ThermalConfig.txt | sed 's/.*\([X,x]\)\([0-9][0-9]\).*/\2/' `
			else
				DRACThermalFileVer=`grep TEMPLATE_REVISION_NUM /etc/default/ipmi/default/ThermalConfig.txt | sed 's/.*\([X,x]\)\([0-9][0-9]\).*/\2/' `
			fi
			# echo "\$ThermalFileVer: $ThermalFileVer"
			# echo "\$DRACThermalFileVer: $DRACThermalFileVer"
			if [ $ThermalFileVer -le $DRACThermalFileVer ] ; then
				ln -sf /flash/data0/persmod/ThermalConfig.txt /flash/data0/BMC_Data/ThermalConfig.txt
				echo "Thermal Config from Identity Module Installed"
			else
				reset_thermalconfig
				echo "Thermal Config from Identity Module with version" $ThermalFileVer "is greater than the iDRAC supported version" $DRACThermalFileVer
				echo "Thermal Config from Identity Module could not be installed"
			fi
	else
		echo "$PM_FILE Does NOT Exist, resetting!"
		reset_thermalconfig
	fi
}


reset_thermalconfig()
{
        if [ $# -ge 1 ] ; then
                if [ $1 = "force" ] ; then
                        force=1
                else
                        force=0
                fi
        else
                force=0
        fi

	id=`/etc/default/ipmi/getsysid`
	if [ -d /tmp/pd0/ipmi/${id} ] ; then \
		ln -sf /tmp/pd0/ipmi/${id}/ThermalConfig.txt /flash/data0/BMC_Data/ThermalConfig.txt
	else
		ln -sf /etc/default/ipmi/default/ThermalConfig.txt /flash/data0/BMC_Data/ThermalConfig.txt
	fi
	echo "Thermal Configuration Reset"
        if [ -e $PM_FILE ] ; then
                echo "Thermal Config File $PM_FILE exists!"
                if [ $force -eq 0 ] ; then
                        echo "Specify force option to delete"
                else
			rm -f $PM_FILE
			echo "$PM_FILE"
                	echo "Thermal Config File $PM_FILE deleted!"
		fi
	fi
}

reset_ipmi()
{
	echo "IPMI Reset"
	res=`ps | grep -i /bin/fullfw | grep -iv grep`
	# echo "1: \$res: [ $res ]"
	if [ -z $res ] ; then
		echo "Process not found"
	else
		echo "Kill IPMI process"
		`killall -9 fullfw`
		while true
		do
			res=`ps | grep -i /bin/fullfw | grep -iv grep`
			# echo "2: \$res: [ $res ]"
			if [ -z $res ] ; then
				break
			fi
			echo "Wait for process to die"
		done
                while true
		do
                        res=`ps | grep -i /bin/fullfw | grep -iv grep`
			# echo "3: \$res: [ $res ]"
                        if [ -z $res ] ; then
				echo "Wait for process to come back alive"
				sleep 1
			else
				# echo "4: \$res: $res"
				break
                        fi
                done
		echo "Done."
	fi
}

echo ""
echo "$0: $1 $2 $3"

case "$1" in
	help)
		help_msg
	;;
	
	install)
		if [ $# -eq 1 ] ; then
			echo "No Config File Specified!"
			exit
		else
			echo "Config File: $2 $3"
			copy_config_file $2 $3
 			setup_cfglib
		fi
	;;

	restore)
		reset_thermalconfig force
                reset_ipmi
	;;

	reset)
		reset_ipmi
	;;
	*)
	;;
esac
