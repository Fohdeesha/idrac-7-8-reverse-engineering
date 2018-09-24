#! /bin/sh

# command line parameters
# $1 file directory to be removed

# return codes:
# 0x00: success
# 0x01: invalid command line parameter

RMDIR=1

#validate the number of command line parameters
if [ $# -eq 1 ]
then
	rm -rf "$1"

	RMDIR=0
else
	if [ $# -eq 2 ]
	then
		if [ -d "$2" ]; then
			rm -fr "$2"
		fi
		mv "$1" "$2"
	else
		echo INCORRECT NUMBER OF PARAMETERS EXPECTED 1 GOT $#
	fi
fi

exit "$RMDIR"

