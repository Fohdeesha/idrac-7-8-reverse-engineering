#!/bin/bash
echo "packages required: squashfs-tools"
sleep 2
mksquashfs livefs test.img -b 262144 -comp lzo
sleep 1
filename=./test.img
maxsize=114915830
filesize=$(stat -c%s "$filename")
echo "Size of $filename = $filesize bytes."

if (( filesize > maxsize )); then
    echo -e '\n'
    echo "Image too big for flash - trim some fat"
	rm -rf test.img
	echo -e '\n'
else
    echo -e '\n'
	echo "built test.img"
    echo "please flash responsibly"
    echo -e '\n'
fi
