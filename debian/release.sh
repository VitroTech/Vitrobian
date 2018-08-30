#!/bin/bash

VITROBIAN_VERSION="$(cat ../VERSION)"
IMAGE_TO_UPLOAD="vitrobian.img.gz"
BMAP_TO_UPLOAD="vitrobian.img.img.bmap"
IMAGE_OUTPUT_NAME="vitrobian_${VITROBIAN_VERSION}.img.gz"
BMAP_OUTPUT_NAME="vitrobian_${VITROBIAN_VERSION}.bmap"

# upload package
[ -z $AWS_PROFILE ] && echo "AWS_PROFILE not given" && exit
[ -z $AWS_BUCKET ] && echo "AWS_PROFILE not given" && exit
aws s3 cp $IMAGE_TO_UPLOAD s3://$AWS_BUCKET/$IMAGE_OUTPUT_NAME --profile $AWS_PROFILE --acl public-read
aws s3 cp $BMAP_TO_UPLOAD s3://$AWS_BUCKET/$BMAP_OUTPUT_NAME --profile $AWS_PROFILE --acl public-read
