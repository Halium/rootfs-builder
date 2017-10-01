#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "At least one argument needed, caf or generic"
    exit 1
fi

export ARCH=armhf

# configure the live-build
lb config \
        --mode ubuntu \
        --distribution $DIST \
        --binary-images none \
        --memtest none \
        --source false \
        --archive-areas "main restricted universe multiverse" \
        --apt-source-archives true \
        --architectures armhf \
        --bootstrap-qemu-arch armhf \
        --bootstrap-qemu-static /usr/bin/qemu-arm-static \
        --linux-flavours none \
        --bootloader none \
        --initramfs-compression lzma \
        --initsystem none \
        --chroot-filesystem plain \
        --apt-options "--yes -o Debug::pkgProblemResolver=true" \
        --compression gzip \
        --system normal \
        --zsync false \
        --linux-packages=none \
        --backports true \
        --apt-recommends false \
        --initramfs=none

. /etc/os-release # to get access to version_codename; NB: of host container!

GPG="gpg"
ARGS=""
if [ "$VERSION_CODENAME" = "bionic" ]; then
  apt install -y dirmngr gnupg1
  ARGS="--batch --verbose"
  GPG="gpg1"
fi

# make caf or generic
sed -i s/VARIANT/$i customization/archives/*.list

# Copy the customization
cp -rf customization/* config/

rm config/archives/halium.key

$GPG --list-keys
$GPG \
  $ARGS \
  --no-default-keyring \
  --primary-keyring config/archives/halium.key \
  --keyserver pool.sks-keyservers.net \
  --recv-keys 'E47F 5011 FA60 FC1D EBB1  9989 3305 6FA1 4AD3 A421'

chmod 644 config/archives/halium.key

# build the rootfs
lb build

# live-build itself is meh, it creates the tarball with directory structure of binary/boot/filesystem.dir
# so we pass --binary-images none to lb config and create tarball on our own
if [ -e "binary/boot/filesystem.dir" ]; then
        (cd "binary/boot/filesystem.dir/" && tar -c *) | gzip -9 --rsyncable > "halium-rootfs-$1.tar.gz"
        chmod 644 "halium.rootfs-$1.tar.gz"
fi
