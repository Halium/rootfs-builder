#!/bin/sh

echo "I: making libhybris the default alternatives for arm-linux-gnueabihf_egl_conf"
update-alternatives --set arm-linux-gnueabihf_egl_conf /usr/lib/arm-linux-gnueabihf/libhybris-egl/ld.so.conf

# ldconfig needs to be run immediately as we're changing /etc/ld.so.conf.d/ with alternatives.
LDCONFIG_NOTRIGGER=y ldconfig
