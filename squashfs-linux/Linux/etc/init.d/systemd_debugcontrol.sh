#!/bin/sh

echo "Initialize debugcontrol tool ..."
# Set the debug controls in the Logging Mechanism to the default values
if [ ! -e /flash/data0/oem_ps/idraclog_ps ]
then
    /bin/debugcontrol -d
fi
