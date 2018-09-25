#! /bin/sh

# command line parameters
# $1 keylength
# $2 Key file path
# $3 public Certificate file path
# $4 Country Code (2 letter)
# $5 State/Province
# $6 Locale
# $7 Organization
# $8 Division
# $9 Name
# $9 (after shift 1) email

# return codes:
# 0x00: success
# 0x01: invalid command line parameter

GENCSR=1

#validate the number of command line parameters
if [ $# -eq 10 ]
then
	keylength=$1
	keyout=$2
	cerout=$3
	city=$4
	state=$5
	locale=$6
	org=$7
	org_unit=$8
	common_name=$9
	shift 1
	email=$9

	#create a file that holds the parameters for the openssl command
	CONFFILE=/tmp/gencer.$$
	cat <<-@eof >$CONFFILE
	[req] 
	prompt = no
	output_password = password
	distinguished_name = dn-param
	attributes = req_attributes
	[dn-param] # DN fields
	C = $city
	ST = $state
	L = $locale
	O = $org
	OU = $org_unit
	CN = $common_name
	emailAddress = $email
	[req_attributes]
	challengePassword = A challenge password
	@eof
else
	if [ $# -eq 9 ]
	then
		keylength=$1
		keyout=$2
		cerout=$3
		city=$4
		state=$5
		locale=$6
		org=$7
		org_unit=$8
		common_name=$9

		echo no email address specified

		#create a file that holds the parameters for the openssl command
		CONFFILE=/tmp/gencer.$$
		cat <<-@eof >$CONFFILE
		[req] 
		prompt = no
		output_password = password
		distinguished_name = dn-param
		attributes = req_attributes
		[dn-param] # DN fields
		C = $city
		ST = $state
		L = $locale
		O = $org
		OU = $org_unit
		CN = $common_name
		[req_attributes]
		challengePassword = A challenge password
		@eof
	else
		echo incorrect number of parameters: expected 9 or 10, got $#
		exit 1
	fi
fi
#echo keylength: $keylength
#echo keyout: $keyout
#echo cerout: $cerout
#echo city: $city
#echo state: $state
#echo locale: $locale
#echo org: $org
#echo org_unit: $org_unit
#echo common_name: $common_name
#echo email: $email

# Generate the Server Certificate, but it doesn't sign it
# the user will need to sign and before upload it
# They can sign it using Verisign or Microsoft CA or other way they like to sign it


# run the openssl command to create the key 
openssl genrsa $keylength > $keyout

# run the openssl command to create self signed certificate 
openssl req -config $CONFFILE -new -x509 -nodes -sha256 -days 365 -key $keyout > $cerout

#remove the file that holds the parameters
rm -f $CONFFILE

# indicate success
GENCSR=0

exit "$GENCSR"

