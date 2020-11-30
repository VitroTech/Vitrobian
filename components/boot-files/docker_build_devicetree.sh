#!/bin/bash

export DEVICETREE_DIR=vitro-crystal-boot-files/boot

if [ ! -d ${DEVICETREE_DIR} ]; then
    echo "${DEVICETREE_DIR} directory does not exist, create one..."
    mkdir -p $DEVICETREE_DIR
fi

docker run --rm -it -e DEVICETREE_DIR -v $PWD:/home/build vitrobian-boot-files /bin/bash -c "./build-from-vitro-forks.sh devicetree ${DEVICETREE_DIR}"