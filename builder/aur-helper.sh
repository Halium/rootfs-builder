#!/bin/bash

set -e

COMMAND=$1
AURHELPER=$2

# Check if AUR Helper is supported
if [ "x$AURHELPER" != "xpacaur" ]; then
	echo "$AURHELPER is not supported" >&2
	exit 1
fi

function install() {
	# Install AUR helper

	# Check running user
	if [ "$USER" == "root" ]; then
		echo "$AURHELPER can't be installed from root !" >&2
		exit 1
	fi

	case $1 in
		pacaur)
			git clone https://aur.archlinux.org/pacaur.git
			cd pacaur
			makepkg -s --install --noconfirm
			cd ..
			rm -rf pacaur
			;;
		*)
			exit 1
			;;
	esac
}

function getflags() {
	# return flags to install a package without interaction
	case $1 in
		pacaur)
			echo "--noconfirm --noedit"
			;;
		*)
			exit 1
			;;
	esac
}

function cleanup() {
	# Clean up some cache files specially to have a clean rootfs
	case $1 in
		pacaur)
			[ -d .cache/pacaur ] && rm -rf .cache/pacaur
			;;
		*)
			exit 1
			;;
	esac
}

# Main

# Go to the root of the user
cd

case $COMMAND in
	install)
		install $AURHELPER
		;;
	getflags)
		getflags $AURHELPER
		;;
	cleanup)
		cleanup $AURHELPER
		;;
	*)
		echo "$COMMAND not supported" >&2
		exit 1
		;;
esac

