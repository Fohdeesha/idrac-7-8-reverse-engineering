# idrac-7-8-reverse-engineering
Achieving undetectable root + loading of arbitrary code on Dell IDRAC7 & IDRAC8 IPMI/BMC hardware. 

# Instructions
The `build-scripts` folder contains basic scripts for modifying and rebuilding the kernel and squashFS images from the official firmware image. Once extracted and unsquashed, you are free to modify the linux filesystem as you please. If you plan on adding binaries, please be aware the onboard IDRAC BMC is SuperH/RISC, details in `iDRAC_opensource_2.60.60.60/externalsrc/linux-yocto/.config` assuming you have dell's IDRAC8 sources (IDRAC7 & IDRAC8 run the same codetrain).

What is **not** covered in this repo is instructions on bypassing Dell's PGP signature checks to load and run your modified firmware onto the controller. These instructions may be added at a later date pending security disclosure. Hint: **u-boot**

```
display_factory_info.sh[2377]: 0x14000000 = 01 00 03 00 02 00 00 00 : 08 00 00 00 01 00 06 0b
display_factory_info.sh[2377]: 0x14000010 = 00 08 08 00 04 00 04 00 : 00 07 0c 09 03 0c 0c 0f
display_factory_info.sh[2377]: 0x14000020 = 07 07 0e 07 00 00 00 00 : 00 00 00 01 00 00 01 01
display_factory_info.sh[2377]: 0x14000030 = 00 00 00 00 00 00 00 00 : 00 00 00 00 00 00 00 00
display_factory_info.sh[2377]: -------------------------------------------
display_factory_info.sh[2377]: Custom Image Booted: v1.1 @J.Sands @A.Nielsen
display_factory_info.sh[2377]: Enjoy Enjoy Enjoy Enjoy
display_factory_info.sh[2377]: -------------------------------------------
display_factory_info.sh[2377]: -------------------------------------------
display_factory_info.sh[2377]: Files Edited:
display_factory_info.sh[2377]: /etc/fsdf/DebugCaps.ini              Removed auth requirement for "racadm debug invoke rootshell"
display_factory_info.sh[2377]: /etc/passwd                          Removed forcing of logins to limited RACADM shell
display_factory_info.sh[2377]: /etc/def_ssh/sshd_config             Removed prevention of root logins
display_factory_info.sh[2377]: /etc/ssh-motd.txt                    Added SSH MOTD
display_factory_info.sh[2377]: /etc/init.d/display_factory_info.sh  Added these messages
display_factory_info.sh[2377]: -------------------------------------------
```

**Special thanks to Adam Nielsen for poking through sources with me over 70+ emails in two timezones**


![drac-1](https://i.imgur.com/NEoeaf7.jpg)

![drac-2](https://i.imgur.com/yQZiCP0.jpg)

![drac-2](https://i.imgur.com/mAbKbew.png)