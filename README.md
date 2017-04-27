# Reference rootfs builder

This live-build configuration is used to build the reference rootfs

# Dependencies

* qemu-arm-static
* live-build

# How to

BUG: live-build shipped in ubuntu is slightly-old and doesn't have bug fix which makes it impossible to create rootfs in ubuntu mode

To workaround this, we modify the `/usr/lib/live/build/lb_chroot_live-packages` and comment out the code to install live-config and live-config-systemd as this package is not present in ubuntu.

Comment out code shown below,

```
# Queue installation of live-config
if [ -n "${LB_INITSYSTEM}" ] && [ "${LB_INITSYSTEM}" != "none" ]
then
       _PACKAGES="${_PACKAGES} live-config live-config-${LB_INITSYSTEM}"
fi
```

TODO: create patched package so its automated

After that run script `build.sh` to build the live image.

# Rootfs

Current rootfs is based on Ubuntu 16.04, and have systemd as main init system
