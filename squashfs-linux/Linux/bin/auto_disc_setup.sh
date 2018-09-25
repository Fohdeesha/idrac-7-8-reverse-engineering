# This script is run in the factory to set up the initial settings on iDRAC for auto discovery
# The settings done in this script are as follows:
#     Enable DHCP
#     Get domain name from DHCP
#     Disable admin account (account 2)
#     Get DNS server from DHCP

export USER=root
export PATH=$PATH:/usr/local/bin

set -x
set -e

for i in `seq 1 20`;
do
        if  ! racadm set iDRAC.Nic.Enable Enabled; then
                echo "Nicenable failed"
        elif  ! racadm set iDRAC.IPv4.DHCPEnable Enabled; then
                echo "set dhcp failed"
        elif  ! racadm set iDRAC.Nic.DNSDomainFromDHCP Enabled; then
                echo "set domain name from dhcp failed"
        elif  ! racadm set iDRAC.Users.2.Enable Disabled; then
                echo "disable admin failed"
        elif  ! racadm set iDRAC.IPv4.DNSFromDHCP Enabled; then
                echo "dns server from dhcp failed"
        elif  ! racadm set iDRAC.IPv4.Enable Enabled; then
                echo "enable ipv4 failed"
        else
            echo "All cmds successful"
            exit 0;
        fi;
        sleep 10
done
exit 1;


