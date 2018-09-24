#!/bin/sh

echo "$1 driver load start at $(date)"

load_ipmi_modules() {
    echo "1 4 1 7" > /proc/sys/kernel/printk

    insmod /lib/modules/aess_video.ko
    dev_major=`grep aess_video /proc/devices | awk '{print $1}'`
    if [ "$dev_major" != "" ]; then
       mkdir -p /dev/avct
       mknod /dev/avct/video c $dev_major 0
    fi

    insmod /lib/modules/aess_eventhandlerdrv.ko
    insmod /lib/modules/aess_kcsdrv.ko
    insmod /lib/modules/aess_biospostdrv.ko
    insmod /lib/modules/aess_gpiodrv.ko
    insmod /lib/modules/aess_sgpiodrv.ko
    insmod /lib/modules/aess_dynairqdrv.ko
    insmod /lib/modules/aess_pecisensordrv.ko
    insmod /lib/modules/aess_fansensordrv.ko
    insmod /lib/modules/aess_pwmdrv.ko
    insmod /lib/modules/aess_adcsensordrv.ko
    insmod /lib/modules/dell_cplddrv.ko

    #insmod /lib/modules/aess_spi1drv.ko
    insmod /lib/modules/VKCSDriver.ko

    ShastaChipId=00003120
    if /bin/MemAccess2 -rl -a ff000044 -c 1 | grep 0xff000044 | grep -q $ShastaChipId
    then
        insmod /lib/modules/i2c_riic.ko
        insmod /lib/modules/aess_i2cdrv_abs.ko
        insmod /lib/modules/3.16.47/kernel/drivers/spi/spi-rspi.ko
    else
        insmod /lib/modules/aess_i2c_hwctrldrv.ko
        insmod /lib/modules/aess_i2cdrv.ko
        insmod /lib/modules/aess_rspidrv.ko
    fi

    # Load these after, the rspi driver has been loaded
    insmod /lib/modules/dell_eerspidrv.ko
    insmod /lib/modules/dell_fpdrv.ko
    modprobe bonding mode=1 miimon=200 use_carrier=1 downdelay=5000
}

load_usb_modules() {
    # Start the sh7757 usb drivers
    # installs udc driver (peripheral controller driver)
    # installs composite driver 
    # installs kbdmouse driver
    # installs mass_storage driver
    # Note: for a configuration that is not full features (ipmi only)
    # the kbdmouse driver is not loaded
    # Startup Dependency: 

    DEVDIR="/dev/avct"
    FULLFEATURES="true"
    VERSION="1.1.0.3"

    #
    # full_features () - check for full features configuration
    # Note - there is no good way to do this.  A non full features
    # configuration (ipmi only) will not include JAVA clients
    #
    # updates global variable FULLFEATUES
    #
    full_features() {
        if [ -f "/usr/local/www/software/avctKVM.jar" ] ; then
            return 1;
        fi;

        echo "NOTICE: Not full features configuration - kbdmouse not operational"
        FULLFEATURES="false"
        return 0;
    }

    #
    # driver_major () - sets global variable 'major' 
    # $1 = driver name
    driver_major() {
        major=$(cat /proc/devices | grep $1 | cut -f1 -d" ")
        [ -n "$major" ] || major=0
    } 

    full_features


    # peripheral controller driver
    #modprobe g_r8a66597_udc

    # hub driver
    modprobe g_hub

    # kbdmouse driver -Port 1
    if [ $FULLFEATURES = "true" ] ; then
        modprobe g_kbdmouse

        driver_major g_kbdmouse
        kbd_major=$major
        if [ $kbd_major -eq 0 ]; then
            return 1
        fi;
    fi;

    # mass_storage driver - Port 2
    modprobe g_mass_storage interfaces=1 vendor="iDRAC"
    driver_major g_mass_storage
    ms_major=$major

    # ETH driver - Port 3
    modprobe g_ether

    # second mass_storage driver -Port 4
    modprobe g_mass_storage1 interfaces=1 vendor="iDRAC"
    driver_major g_mass_storage1
    ms1_major=$major

    # third mass_storage driver - Port 5
    modprobe g_mass_storage2 interfaces=1 vendor="iDRAC"
    driver_major g_mass_storage2
    ms2_major=$major

    # fourth mass_storage driver - Port 6
    modprobe g_mass_storage3 interfaces=1 vendor="iDRAC"
    driver_major g_mass_storage3
    ms3_major=$major

    # ETH1 driver - USBPORT1 - Func 0 or Func 6
    modprobe g_ether_usb

    # EHCI driver
    #modprobe ehci-hcd

    # OHCI driver
    #modprobe ohci-hcd

    # SCSI MOD driver
    modprobe scsi_mod

    # SD MOD driver
    modprobe sd_mod

    # USB Storage driver
    modprobe usb-storage

    # non-ipmi modules
    modprobe aess_timerdrv
    modprobe sh_pbi
    modprobe usbmux_drv

    if [ ! -e $DEVDIR ]; then
        mkdir $DEVDIR
    fi;

    if [ $FULLFEATURES = "true" ] ; then
        mknod "$DEVDIR/usb_keyboard" "c" $kbd_major 0
        mknod "$DEVDIR/usb_mouse" "c" $kbd_major 1
    fi;

    mknod $DEVDIR/usb_iface1 c $ms_major  0
    mknod $DEVDIR/usb_iface2 c $ms1_major 0
    mknod $DEVDIR/usb_iface3 c $ms2_major 0
    mknod $DEVDIR/usb_iface4 c $ms3_major 0

    # for usb-storage
    mknod "$DEVDIR/../sda" "b" 8 0

	#remove usb ethernet driver which should not be loaded.
	rmmod g_ether
}

# usb drivers are not critical, so we can consider loading complete here
if [ "$1" = "usb" ]; then
    load_usb_modules
elif [ "$1" = "ipmi" ]; then
    load_ipmi_modules
fi
echo "$1 driver load done at $(date)"
