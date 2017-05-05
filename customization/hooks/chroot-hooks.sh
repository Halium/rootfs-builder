#!/bin/bash

set -e

# $1 is used to pass DEBUG flag (0: no debug, else: debug)
if [ ${1-0} -eq 0 ]; then
	OUTPUT_FILTER="&> /dev/null"
	SH_SET="-e"
else
	OUTPUT_FILTER=""
	SH_SET="-ex"
	set -ex
fi

AURHELPER=pacaur
ADDITIONAL_BASE_PACKAGES="base-devel git vim bash-completion"
SUDO_USER=alarm

# Go to the parent directory of the directory script
cd $(dirname $(dirname $(readlink -f $0)))

# chroot_early scripts
echo "(chroot) Executing hooks/*.chroot_early"
for file in $(find hooks/ -name "*.chroot_early"); do
	echo " => running $file"
	eval sh $SH_SET $file $OUTPUT_FILTER
done

# Update the system
echo "(chroot) Updating all packages..."
eval pacman -Syu --noconfirm $OUTPUT_FILTER

# Install early minimal requirements
echo "(chroot) Installing additional base packages"
eval pacman -S --noconfirm $ADDITIONAL_BASE_PACKAGES $OUTPUT_FILTER

# Sudo - (wheel group will be able to request high privileges without password. alarm is on this group and will permit to support AUR packages installation)
echo "(chroot) sudo configuration"
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Install AUR helper (pacaur)
echo "(chroot) Installing AUR helper ($AURHELPER)"
eval sudo -u $SUDO_USER -i -- sh $SH_SET $PWD/hooks/aur-helper.sh install $AURHELPER $OUTPUT_FILTER

# Install package-lists/*.chroot
echo "(chroot) Installing package-lists/*.chroot"
if [ -n "$(cat package-lists/*.chroot | tr '\n' ' ')" ]; then
	echo ' => /!\ Can be long if some packages need to be compiled from AUR. Please be patient ...'
	AURHELPER_FLAGS=$(sh hooks/aur-helper.sh getflags $AURHELPER)
	eval sudo -u $SUDO_USER -i -- $AURHELPER -S $AURHELPER_FLAGS $(cat package-lists/*.chroot | tr '\n' ' ') $OUTPUT_FILTER
fi

# chroot scripts
echo "(chroot) Executing hooks/*.chroot"
for file in $(find hooks/ -name "*.chroot"); do
	echo " => running $file"
	eval sh $SH_SET $file $OUTPUT_FILTER
done

# Clean up
echo "(chroot) Cleaning up"
rm -f /var/cache/pacman/pkg/*.tar.xz
eval sudo -u $SUDO_USER -i -- sh $SH_SET $PWD/hooks/aur-helper.sh cleanup $AURHELPER $OUTPUT_FILTER

