#!/bin/bash

OUT_DIR="vitro-crystal-boot-files"
BOOT_DIR="$OUT_DIR/boot"
UBOOT_DIR="$BOOT_DIR/u-boot"
VITROBIAN_VERSION="$(cat VERSION)"

rm -rf $OUT_DIR
mkdir -p $UBOOT_DIR

# build U-Boot
./build-from-vitro-forks.sh u-boot $UBOOT_DIR

# build devicetree
./build-from-vitro-forks.sh devicetree $BOOT_DIR

# build boot script
mkimage -A arm -O linux -T script -C none -d boot.cmd $UBOOT_DIR/boot.scr

# package boot files
TARBALL="${OUT_DIR}_${VITROBIAN_VERSION}.tar.gz"
tar zcvf $TARBALL $OUT_DIR
