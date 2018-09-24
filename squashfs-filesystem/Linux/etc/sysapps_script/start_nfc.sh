

cd /tmp/
#tftp -g -r nfc 10.210.130.95 .
cp /etc/sysapps_script/nfc .
chmod 777 nfc
ln -s /usr/lib/libcpld.so.1.2.3 libcplddrv.so

ln -s /usr/lib/libi2c.so.1.2.3 libi2c.so

ln -s /usr/lib/libgpio.so.1.2.3 libgpio.so

export LD_LIBRARY_PATH=/tmp

./nfc

echo -n "NFC init done"



