#!/etc/bash
if [ -n "$1" ]; then
    iteration=$1
else
    iteration=0
fi
timestamp=`date`
build=`head -1 /etc/fw_ver`
semaphores=`ipcs -s -u | grep semaphores | awk '{print $4}'`
if [ $iteration -eq 0 ]; then
    echo "Semaphores,Iteration,Timestamp,Build" > /tmp/sem_usage.csv
    echo "Generating /tmp/sem_usage.csv file"
fi
echo "Semaphore Usage Iteration $iteration, $timestamp"

echo "$semaphores,$iteration,$timestamp,$build" >> /tmp/sem_usage.csv
echo "Done"
