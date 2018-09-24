$$$$$$$$$$$$$$$$$$$$$$$$$$$
	README
$$$$$$$$$$$$$$$$$$$$$$$$$$$

To Debug Systemd service files:
  mkdir -p /flash/data0/debug/systemd
  cp -rf /lib/systemd/system /flash/data0/debug/systemd
    edit changes to service files in /flash/data0/debug/systemd/system
  echo COUNT=10 > /flash/data0/debug/idrac-debug	
    (COUNT will decrement every reboot; 
     when becomes '0'/flash/data0/debug/systemd will be erased and resume normal boot)

Following scripts runs if available after ps.service and dm-stage2.service respectively.
  /flash/data0/debug/preinit.sh
  /flash/data0/debug/postinit.sh 
