#!/bin/bash

export UBOOT_DIR=vitro-crystal-boot-files/boot/u-boot

if [ ! -d ${UBOOT_DIR} ]; then
    echo "${UBOOT_DIR} directory does not exist, create one..."
    mkdir -p $UBOOT_DIR
fi

docker run --rm -it -e UBOOT_DIR -v $PWD:/home/build vitrobian-boot-files /bin/bash -c "./build-from-vitro-forks.sh u-boot ${UBOOT_DIR}"