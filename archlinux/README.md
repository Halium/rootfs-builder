# Archlinux ARM root builder

## Dependencies

read: https://wiki.archlinux.org/index.php/Raspberry_Pi#QEMU_chroot

```
Install binfmt-support and qemu-user-static from AUR

systemctl enable binfmt-support
systemctl start binfmt-support

update-binfmts --display qemu-arm
update-binfmts --display qemu-aarch64

update-binfmts --enable qemu-arm
update-binfmts --enable qemu-aarch64
```

## Build

Simply run the following to generate the rootfs

```
make
```

### Direct working on the build for debug

```
make mount

sudo chroot build  /bin/sh
<ctrl+D>

make umount
```

