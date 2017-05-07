#rootfs for Archlinux ARM

DEBUG ?= 0
DISTCC ?= 0

ARMHOST=$(shell [ $(shell uname -m) == "armv7l" ] && echo 1 || echo 0 )

SRCDIR=src
BUILDDIR=build
CUSTOMIZATION=customization

SUDO=/usr/bin/sudo

ifeq ($(ARMHOST),0)
QEMU=/usr/bin/qemu-arm-static
QEMU64=/usr/bin/qemu-aarch64-static
else
QEMU=
QEMU64=
endif

ARCHLINUX_OTA_ARCH=armv7
ARCHLINUX_SYSTEM_IMAGE_FILE=ArchLinuxARM-$(ARCHLINUX_OTA_ARCH)-latest.tar.gz
ARCHLINUX_SYSTEM_IMAGE_URL=https://archlinuxarm.org/os/$(ARCHLINUX_SYSTEM_IMAGE_FILE)

SRC_ARCHLINUX_SYSTEM_IMAGE_FILE=$(SRCDIR)/$(ARCHLINUX_SYSTEM_IMAGE_FILE)

ARCHLINUX_ROOTFS=halium.rootfs.tar.gz

all: $(ARCHLINUX_ROOTFS)

$(ARCHLINUX_ROOTFS): $(SUDO) $(BUILDDIR) .rootfs
	$(info Building $(ARCHLINUX_ROOTFS))
	@$(SUDO) tar czf $@ -C $(BUILDDIR) .
	@$(SUDO) chown $(USER):$(shell id -g -n $(USER)) $@
	@echo "Completed: $(ARCHLINUX_ROOTFS)"

$(SRC_ARCHLINUX_SYSTEM_IMAGE_FILE): $(SRCDIR)
	$(info Downloading GNU/Linux Image: $(ARCHLINUX_SYSTEM_IMAGE_FILE))
	@curl -L $(ARCHLINUX_SYSTEM_IMAGE_URL) -o $@

.extract: $(SUDO) $(BUILDDIR) $(SRC_ARCHLINUX_SYSTEM_IMAGE_FILE)
	$(info Extracting $(ARCHLINUX_SYSTEM_IMAGE_FILE))
	@$(SUDO) tar --numeric-owner -xzf $(SRC_ARCHLINUX_SYSTEM_IMAGE_FILE) -C $(BUILDDIR) 2> /dev/null
	@touch .extract

.mount: .extract mount
	@touch .mount

.umount: .mount umount
	@touch .umount

.patch-rootfs: $(SUDO) $(BUILDDIR) .mount
	$(info Patching rootfs)
	@$(SUDO) chroot $(BUILDDIR) /bin/sh /home/.$(CUSTOMIZATION)/hooks/chroot-hooks.sh $(DEBUG) "$(DISTCC)"
	@touch .patch-rootfs

.rootfs: .patch-rootfs .umount
	@touch .rootfs

.mount-manual: $(SUDO) $(QEMU) $(QEMU64) $(BUILDDIR) $(CUSTOMIZATION) .extract
	$(info Preparing the build)
	@$(SUDO) mount --bind $(BUILDDIR) $(BUILDDIR)
	@$(SUDO) mount --bind /dev $(BUILDDIR)/dev
	@$(SUDO) mount --bind /proc $(BUILDDIR)/proc
	@$(SUDO) mount --bind /sys $(BUILDDIR)/sys
	@$(SUDO) mount --bind /tmp $(BUILDDIR)/tmp
	@$(SUDO) mv $(BUILDDIR)/etc/resolv.conf $(BUILDDIR)/etc/resolv.conf.bak
	@$(SUDO) cp /etc/resolv.conf $(BUILDDIR)/etc/resolv.conf
	@$(SUDO) cp -r $(CUSTOMIZATION) $(BUILDDIR)/home/.$(CUSTOMIZATION)
	@if [ $(ARMHOST) -eq 0 ]; then \
		$(SUDO) cp $(QEMU) $(BUILDDIR)/usr/bin/ ;\
		$(SUDO) cp $(QEMU64) $(BUILDDIR)/usr/bin/ ;\
	fi
	@touch .mount-manual

mount: .mount-manual

umount: $(SUDO) $(BUILDDIR)
	$(info Cleaning up the build)
	@$(SUDO) umount $(BUILDDIR)/dev
	@$(SUDO) umount $(BUILDDIR)/proc
	@$(SUDO) umount $(BUILDDIR)/sys
	@$(SUDO) umount $(BUILDDIR)/tmp
	@$(SUDO) umount $(BUILDDIR)
	@$(SUDO) mv $(BUILDDIR)/etc/resolv.conf.bak $(BUILDDIR)/etc/resolv.conf
	@$(SUDO) rm -rf $(BUILDDIR)/home/.$(CUSTOMIZATION)
	@if [ $(ARMHOST) -eq 0 ]; then \
		$(SUDO) rm $(BUILDDIR)$(QEMU) ;\
		$(SUDO) rm $(BUILDDIR)$(QEMU64) ;\
	fi
	@rm -f .mount-manual

$(SRCDIR):
	@mkdir -p $(SRCDIR)

$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

.PHONY: clean clean-image clean-$(SCRDIR) mrproper

clean: $(SUDO)
	$(shell [ -f .mount-manual ] && make umount )
	$(SUDO) rm -rf $(BUILDDIR)
	rm -f .extract
	rm -f .mount
	rm -f .umount
	rm -f .patch-rootfs
	rm -f .rootfs

clean-image:
	rm -rf $(SRC_ARCHLINUX_SYSTEM_IMAGE_FILE)

clean-$(SRCDIR):
	rm -rf $(SRCDIR)

mrproper: clean clean-$(SRCDIR)
	rm -rf $(ARCHLINUX_ROOTFS)
