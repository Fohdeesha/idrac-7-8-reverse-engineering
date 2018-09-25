#! /bin/sh

# command line parameters
# $1 CSR key path
# $2 Signed cert path

# return codes:
# 0x00: success
# 0x01: invalid command line parameter

VALIDCERT=1

#validate the number of command line parameters
if [ $# -eq 2 ]
then
echo param1 $1
echo param2 $2

	openssl rsa -passin pass:password -in $1 -noout -modulus > /tmp/keymodulus.txt

	openssl x509 -in $2 -noout -modulus > /tmp/certmodulus.txt
	diff /tmp/keymodulus.txt /tmp/certmodulus.txt > /tmp/modulusdiff.txt

#	rm -f /tmp/keymodulus.txt
#	rm -f /tmp/certmodulus.txt

# HOW CAN WE USE GREP TO DETERMINE IF DIFF OUTPUTS ANYTHING INSTEAD OF REDIRECTING DIFF OUTPUT TO A FILE?
	if [ -s /tmp/modulusdiff.txt ]
	then
		echo -s /tmp/modulusdiff.txt is reporting file exists, indicates diff in key and cert files
	else
		echo -e /tmp/modulusdiff.txt reporting file does NOT exist, indicates key and cert files match
		VALIDCERT=0
	fi

#	rm -f /tmp/modulusdiff.txt
else
	echo INCORRECT NUMBER OF PARAMETERS EXPECTED 2 GOT $#
fi

exit "$VALIDCERT"

