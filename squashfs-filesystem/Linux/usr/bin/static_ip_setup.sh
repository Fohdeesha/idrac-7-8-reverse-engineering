# This script is run during auto discovery re-init when the static IP setting is specified

export PATH=$PATH:/usr/local/bin

racadm config -g cfgLanNetworking -o cfgNicUseDhcp 0
racadm config -g cfgLanNetworking -o cfgDNSServersFromDHCP 0
racadm config -g cfgLanNetworking -o cfgDNSDomainNameFromDHCP 0
racadm config -g cfgLanNetworking -o cfgNicIpAddress $1
racadm config -g cfgLanNetworking -o cfgNicNetmask $2
racadm config -g cfgLanNetworking -o cfgNicGateway $3
racadm config -g cfgLanNetworking -o cfgDNSServer1 $4
racadm config -g cfgLanNetworking -o cfgDNSDomainName $5
