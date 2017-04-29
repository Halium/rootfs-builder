#!/bin/bash
set -e

# Go to the directory of the script
cd $(dirname $(dirname $(readlink -f $0)))

# chroot_early scripts
for file in $(ls -1 hooks/*.chroot_early); do
	sh -e $file
done

# Update the system, install package-lists and cleanup pacman cache
pacman -Syu --noconfirm
pacman -S --noconfirm $(cat package-lists/*.chroot | tr '\n' ' ')
rm -f /var/cache/pacman/pkg/*.tar.xz

# chroot scripts
for file in $(ls -1 hooks/*.chroot); do
	sh -e $file
done

