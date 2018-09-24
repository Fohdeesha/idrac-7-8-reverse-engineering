#!/bin/sh

SYS_SCRIPT_PATH=/etc/sysapps_script
SYS_CONF_PATH=/etc/sysconfig
RESET_LIST=ResetList.conf
RESTART_LIST=RestartList.conf
LOCKFILE=/var/lock/r2default.lock

RM="/bin/rm -rf"
TOUCH=/bin/touch

# action starting
echo "Reset to Default action is starting ..."

# check lock file existed
if [ ! -e ${LOCKFILE} ]; then
	${TOUCH} ${LOCKFILE}
fi

# invoke reset script
exec 9<&0 <${SYS_CONF_PATH}/${RESET_LIST}

while read RESET_FILE
do
	case "RESET_FILE" in
		""|\#*)
			continue;
			;;
	esac
	${SYS_SCRIPT_PATH}/${RESET_FILE} reset
#	echo ${RESET_FILE}
done

echo "Reset action is done ..."
sleep 3

if [ ! -e /etc/hosts ];then
#  echo "File not found"
  cp /etc/default/hosts /flash/data0/etc/hosts
#  echo "Creating soft link"
  ln -s /flash/data0/etc/hosts /etc/hosts
fi

#echo "Checking for etc hosts for ZERO SIZE"
if [ ! -s /etc/hosts ];then
#  echo "/etc/hosts is size ZERO";
  cp /etc/default/hosts /flash/data0/etc/hosts
#  echo "copied /etc/hosts to flash";
fi

# invoke restart script
exec 9<&0 <${SYS_CONF_PATH}/${RESTART_LIST}

while read RESTART_FILE
do
	case "RESTART_FILE" in
		""|\#*)
			continue;
			;;
	esac
	${SYS_SCRIPT_PATH}/${RESTART_FILE} restart
#	echo ${RESTART_FILE}
done

echo "Restart action is done ..."

# remove lock file
if [ -e ${LOCKFILE} ]; then
	${RM} ${LOCKFILE}
fi

# action finished
echo "Reset to Default action is done ..."
