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
echo -e " \n"

echo "-------------------------------------------"
echo "Custom Image Booted: v1.1 @J.Sands @A.Nielsen"
echo "Enjoy Enjoy Enjoy Enjoy"
echo "-------------------------------------------"
echo -e " \n"
echo "-------------------------------------------"
echo "Files Edited:"
echo -e " \n"
echo "/etc/fsdf/DebugCaps.ini              Removed auth requirement for \"racadm debug invoke rootshell\""
echo "/etc/passwd                          Removed forcing of logins to limited RACADM shell"
echo "/etc/def_ssh/sshd_config             Removed prevention of root logins"
echo "/etc/ssh-motd.txt                    Added SSH MOTD"
echo "/etc/init.d/display_factory_info.sh  Added these messages"
echo "-------------------------------------------"
