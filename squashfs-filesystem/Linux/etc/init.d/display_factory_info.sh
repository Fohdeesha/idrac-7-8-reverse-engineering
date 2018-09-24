#!/bin/sh

echo "cat /etc/fw_ver"
cat /etc/fw_ver
echo -e " \n"

echo "cat /proc/cmdline"
cat /proc/cmdline
echo -e " \n"

echo "cat /tmp/loguboot"
cat /tmp/loguboot
echo -e " \n"

echo "/bin/MemAccess -ww ffec0030 5500"
/bin/MemAccess -ww ffec0030 5500
echo -e " \n"

echo "/bin/MemAccess -rb 0x14000000"
/bin/MemAccess -rb 0x14000000
echo -e " \n"


