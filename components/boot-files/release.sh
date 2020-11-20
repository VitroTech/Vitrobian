#!/bin/bash

VITROBIAN_VERSION="$(cat ../../VERSION)"
OUT_DIR="vitro-crystal-boot-files"
TARBALL="${OUT_DIR}_${VITROBIAN_VERSION}.tar.gz"

# upload package
[ -z $AWS_PROFILE ] && echo "AWS_PROFILE not given" && exit
[ -z $AWS_BUCKET ] && echo "AWS_BUCKET not given" && exit
aws s3 cp $TARBALL s3://$AWS_BUCKET --profile $AWS_PROFILE --acl public-read
