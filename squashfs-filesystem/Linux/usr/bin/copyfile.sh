#! /bin/sh

# command line parameters
# $1 file src
# $2 file dest

# return codes:
# 0x00: success
# 0x01: invalid command line parameter
CERTFLAG=/etc/certs/CA/.certflag
FILECPY=1
#validate the number of command line parameters
if [ $# -eq 2 ]
then
	cp $1 $2

	FILECPY=0
    #Set Cert. Flag to "Custom SSL"
    echo "2" > "${CERTFLAG}"
else
	echo INCORRECT NUMBER OF PARAMETERS EXPECTED 2 GOT $#
fi

exit "$FILECPY"

