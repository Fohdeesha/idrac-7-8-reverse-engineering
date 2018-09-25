#!/bin/sh

DEBUG=1
dbecho ()
{
    echo "${1}"
        if [ ! -z "${DEBUG}" ]; then
                echo "${1}" >> /tmp/dhcp.out
        fi
}

dbecho "${interface}: DHCPv4 script:"
dbecho "  Command     : $1"
dbecho "  Interface   : ${interface}"
dbecho "  IP Address  : ${ip}"
dbecho "  Subnet Mask : ${subnet}"
dbecho "  Routers     : ${router}"
dbecho "  DNS Servers : ${dns}"
dbecho "  Hostname    : ${hostname}"
dbecho "  Domain      : ${domain}"
dbecho "  Vendor opt  : ${vendopts}"
dbecho "  Vendor opt15: ${vendopts_option15}"

