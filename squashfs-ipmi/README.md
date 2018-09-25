
# IPMI filesystem
These are the contents of the secondary squashfs filesystem that gets mounted on DRAC boot, containing the IPMI config files for general platform control (fan logic, etc). There is a folder for each server model, by codename. To find out the codename > server model correlation, check the `platcfggrp.txt` in each codename folder: it contains the proper name.

For Instance:
```
Orca       = R720
OrcaS      = R720XD
Madone     = R620
Icon       = R820
Slice      = R420
Defy       = R320
Ghostrider = T620
Mojo       = M620
Sandstorm  = R730
Ratchet    = R330
Prowl      = R630
Megatron   = T630
```

# Thermal / Fans
The logic used by the BMC for chassis fan control and temperature regulation is located in `ThermalConfig.txt` & `ThermalData.txt` in the respective codename folder. These can easily be edited to bypass some of the more arbitrary fan control decisions, such as setting the fans to a much too high static 75% when an unrecognized x16 PCI-E device is installed (consumer video card).

