#!/bin/bash

export BOOT_SCRIPT_DIR=vitro-crystal-boot-files/boot/u-boot

if [ ! -d ${BOOT_SCRIPT_DIR} ]; then
    echo "${BOOT_SCRIPT_DIR} directory does not exist, create one..."
    mkdir -p $BOOT_SCRIPT_DIR
fi

docker run --rm -it -e BOOT_SCRIPT_DIR -v $PWD:/home/build vitrobian-boot-files /bin/bash -c "mkimage -A arm -O linux -T script -C none -d boot.cmd $BOOT_SCRIPT_DIR/boot.scr"