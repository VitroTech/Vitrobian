#!/bin/bash

docker run --rm -it -v $PWD:/home/build vitrobian-boot-files /bin/bash -c "./build.sh"