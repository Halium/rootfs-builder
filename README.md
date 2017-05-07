# Archlinux ARM root builder

## Dependencies

### build from x86_64
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

### build from ARM with distcc cross-compilation on x86_64

read: https://archlinuxarm.org/wiki/Distcc_Cross-Compiling

## Build

Simply run the following to generate the rootfs

```
make
```

### Build (debug mode)

This mode will force -ex and output of all commands into the chroot

```
make DEBUG=1
```

### Distcc

```
make DISTCC="ip1 ip2 ip..."
```

### Chroot into the build

```
make mount

sudo chroot build  /bin/sh
<ctrl+D>

make umount
```

