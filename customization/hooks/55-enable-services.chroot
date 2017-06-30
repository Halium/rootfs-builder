#!/bin/sh -x

systemctl enable system.mount
systemctl enable android-mount.service

#systemctl enable adbd.service
systemctl enable usb-tethering
systemctl enable dropbear

systemctl enable lxc@android.service

systemctl set-default multi-user.target
