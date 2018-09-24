#! /bin/sh -x
set -o errexit

csrconf_gen() {
	cat <<-EOF
	[req]
	prompt = no
	output_password = password
	distinguished_name = dn-param
	attributes = req_attributes
	req_extensions = v3_req

	[dn-param]
	C = $country
	ST = $state
	L = $loc
	O = $org
	OU = $org_unit
	CN = $common_name
	$(test "$email" && echo "emailAddress = $email")

	[v3_req]
	basicConstraints = CA:FALSE
	keyUsage = nonRepudiation, digitalSignature, keyEncipherment
	subjectAltName = @alt_names

	[alt_names]
	$(alt_names "$sans")

	[req_attributes]
	EOF
}

alt_names() {
	# If the SANs weren't specified, we copy the common name to the SAN field.
	if [[ -z "$@" ]]; then
		echo "DNS.0 = $common_name"
	fi

	san_ip_no=0
	san_dns_no=0
	echo "$@" | while read -r; do
		if [ -z "$REPLY" ]; then
			continue;
		fi

		if [ "$REPLY" != "${REPLY#*[0-9].[0-9]}" ]; then
			echo "IP.$san_ip_no = $REPLY"
			let san_ip_no=san_ip_no+1
		elif [ "$REPLY" != "${REPLY#*:[0-9a-fA-F]}" ]; then
			echo "IP.$san_ip_no = $REPLY"
			let san_ip_no=san_ip_no+1
		else
			echo "DNS.$san_dns_no = $REPLY"
			let san_dns_no=san_dns_no+1
		fi
	done
}

main() {
	while getopts :s:e: opt; do
		case $opt in
			s) export sans="$(echo "$OPTARG" | tr -s ', ' '\n')" ;;
			e) export email="$OPTARG" ;;
			'?') exit 1 ;;
		esac
	done
	shift $((OPTIND - 1))

	test "$#" -ge "9"
	export keylen=$1
	export outkey=$2
	export outcsr=$3
	export country=$4
	export state=$5
	export loc=$6
	export org=$7
	export org_unit=$8
	export common_name=$9

	csrconf=$(mktemp)
	csrconf_gen >$csrconf
	openssl req \
		-newkey rsa:$keylen \
		-sha256 \
		-keyout $outkey \
		-out $outcsr \
		-config $csrconf
	rm $csrconf

	# Remove the passphrase from the key
	tempkey=$(mktemp)
	cp $outkey $tempkey
	openssl rsa -in $tempkey -out $outkey -passin pass:password
	rm $tempkey
}

main "$@"

# vim: set ts=2 sw=2:
