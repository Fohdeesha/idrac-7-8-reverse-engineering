#!/bin/sh

CGROUP_C=/sys/fs/cgroup/memory/idrac/C
CGROUP_NC=/sys/fs/cgroup/memory/idrac/NC
CGROUP_IDRAC=/sys/fs/cgroup/memory/idrac
EXIT_STATE=0

if [ ! -d $CGROUP_IDRAC ]; then
	mkdir $CGROUP_IDRAC
else
	count="$( find $CGROUP_IDRAC -type d -mindepth 1 -maxdepth 1 | wc -l )"
	if [ $count -gt 0 ]; then
		echo  -e "Cgroup init failed:Child directories have already been created"
		EXIT_STATE=1
	fi
fi
echo 1 >  $CGROUP_IDRAC/memory.use_hierarchy
#create C and NC groups
mkdir -p $CGROUP_C
mkdir -p $CGROUP_NC

echo 1 >  $CGROUP_C/memory.use_hierarchy
echo 1 >  $CGROUP_NC/memory.use_hierarchy

exit $EXIT_STATE






