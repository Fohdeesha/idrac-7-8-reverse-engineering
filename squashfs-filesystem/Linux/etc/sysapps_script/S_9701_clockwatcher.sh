#!/bin/sh
# run the clockwatcher command line program at boot time

/usr/bin/clockwatcher bootcheck </dev/null >/dev/null 2>&1 &

exit 0

# vim:expandtab:tabstop=4:shiftwidth=4
