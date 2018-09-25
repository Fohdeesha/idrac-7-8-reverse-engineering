BASE_FILE="/etc/fw_ver"
PLATFORM_FILE="/flash/data0/BMC_Data/ID_devid.bin"
READ_COMM="read_id_devid $PLATFORM_FILE"

X=`head -n 1 $BASE_FILE`
echo "Base version : $X"

X="`$READ_COMM 2`.`$READ_COMM 3`.`$READ_COMM 11``$READ_COMM 12``$READ_COMM 13``$READ_COMM 14`" 
echo "Platform version : $X"
