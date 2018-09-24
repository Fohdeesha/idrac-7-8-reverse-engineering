# This script is used when the signed certificates and public keys is transported
# from the customer to CFI securely
# add PATH to enable racadm use
#export PATH=$PATH:/usr/local/bin

ERROR_FILE="/tmp/STAG_client_error"
IN_PROGRESS_FILE="/tmp/cert_script_pending_flag"

#fault code
NO_DIRTOWRITE=1
FILE_MISSING=2

if [ -d "/flash/data0/cv" ] ; then
   PERSISTENT_DIR="/flash/data0/cv"
else
   echo $NO_DIRTOWRITE no directory to move file to >> $ERROR_FILE
   exit 1;
fi

# import_cert_script_flag is used as the indication of file move completion
cd $PERSISTENT_DIR
touch $IN_PROGRESS_FILE
rm -f $ERROR_FILE

# mount MFGDRV maser drive
mkdir /tmp/MFGDRV
mount -t vfat -o loop /tmp/images/MFGDRV.img /tmp/MFGDRV

#cd /tmp
# mkdir /NVRAM
# take user parameter

#move PEM files
if [ $1 -eq 1 ]; then
	if [ -e "/tmp/MFGDRV/CUSCLNT.PEM" ]; then
		echo "mv CUSCLNT.PEM $PERSISTENT_DIR"
		mv /tmp/MFGDRV/CUSCLNT.PEM $PERSISTENT_DIR
	else
		echo $FILE_MISSING CUSCLNT.PEM is missing >> $ERROR_FILE
	fi
fi

if [ $1 -eq 2 ]; then
	if [ -e "/tmp/MFGDRV/CUSSRVPB.PEM" ]; then
		echo "mv CUSSRVPB.PEM $PERSISTENT_DIR"
		mv /tmp/MFGDRV/CUSSRVPB.PEM $PERSISTENT_DIR
	else
		echo $FILE_MISSING CUSSRVPB.PEM is missing >> $ERROR_FILE
	fi
fi

umount -d /tmp/MFGDRV
rmdir /tmp/MFGDRV

echo "remove import_cert_script_flag"
rm -f $IN_PROGRESS_FILE

