#!/bin/bash

VITROBIAN_VERSION="$(cat ../VERSION)"
IMAGE_TO_UPLOAD="vitrobian.img.gz"
BMAP_TO_UPLOAD="vitrobian.img.img.bmap"
IMAGE_OUTPUT_NAME="vitrobian_${VITROBIAN_VERSION}.img.gz"
BMAP_OUTPUT_NAME="vitrobian_${VITROBIAN_VERSION}.bmap"
IMAGE_OUTPUT_NAME_SHA256="${IMAGE_OUTPUT_NAME}.sha256"
IMAGE_OUTPUT_NAME_SIG="${IMAGE_OUTPUT_NAME}.sig"
IMAGE_OUTPUT_NAME_SIG_VAULT="${IMAGE_OUTPUT_NAME}.vault"
BMAP_OUTPUT_NAME_SHA256="${BMAP_OUTPUT_NAME}.sha256"
BMAP_OUTPUT_NAME_SIG="${BMAP_OUTPUT_NAME}.sig"
BMAP_OUTPUT_NAME_SIG_VAULT="${BMAP_OUTPUT_NAME}.vault"

function errorExit {
    errorMessage="$1"
    echo "$errorMessage"
    help
    exit 1
}

function errorCheck {
    errorCode=$?
    errorMessage="$1"
    [ "$errorCode" -ne 0 ] && errorExit "$errorMessage : ($errorCode)"
}

function help {
    echo "Script for upload the vitrobian image to the S3. It assumes that the image files are in the working directory"
    echo "e.g. command"
    echo "VAULT_TOKEN=token AWS_PROFILE=vitro_dev AWS_BUCKET=vitro_dev_img ${0}"
    exit 0
}

function install_vault {
    echo "Installing vault CLI, sudo password will be needed"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update
    sudo apt-get -y install vault
}

# create versioned files

cp "${IMAGE_TO_UPLOAD}" "${IMAGE_OUTPUT_NAME}"
cp "${BMAP_TO_UPLOAD}" "${BMAP_OUTPUT_NAME}"

# check if vault is installed on the system and install if not
vault --version &> /dev/null || install_vault

[ ! -z "$VAULT_TOKEN" ]
errorCheck "VAULT_TOKEN not given"

# we use vault CLI, not API
export VAULT_AGENT_ADDR="https://keystore-vault.dev.vitro.io"
export KEY_NAME="digicert_signing"

# Compute hash locally to avoid uploading data just to be hashed
openssl sha256 -binary "${IMAGE_OUTPUT_NAME}" | base64 > "${IMAGE_OUTPUT_NAME_SHA256}"
errorCheck "Failed to compute sha256 hash for ${IMAGE_OUTPUT_NAME}"

openssl sha256 -binary "${BMAP_OUTPUT_NAME}" | base64 > "${BMAP_OUTPUT_NAME_SHA256}"
errorCheck "Failed to compute sha256 hash for ${BMAP_OUTPUT_NAME}"

# Sign the hash
vault write -field=signature "transit/sign/${KEY_NAME}" \
  input=@"${IMAGE_OUTPUT_NAME_SHA256}" \
  prehashed=true \
  hash_algorithm=sha2-256 \
  signature_algorithm=pkcs1v15 > "${IMAGE_OUTPUT_NAME_SIG_VAULT}"
errorCheck "Failed to sign ${IMAGE_OUTPUT_NAME} sha256 hash using vault"

vault write -field=signature "transit/sign/${KEY_NAME}" \
  input=@"${BMAP_OUTPUT_NAME_SHA256}" \
  prehashed=true \
  hash_algorithm=sha2-256 \
  signature_algorithm=pkcs1v15 > "${BMAP_OUTPUT_NAME_SIG_VAULT}"
errorCheck "Failed to sign ${BMAP_OUTPUT_NAME} sha256 hash using vault"

# Verify the signature with the Vault
vault write "transit/verify/${KEY_NAME}" \
  input=@"${IMAGE_OUTPUT_NAME_SHA256}" \
  prehashed=true \
  hash_algorithm=sha2-256 \
  signature_algorithm=pkcs1v15 \
  signature=@"${IMAGE_OUTPUT_NAME_SIG_VAULT}"
errorCheck "Failed to verify ${IMAGE_OUTPUT_NAME} signature using vault"

vault write "transit/verify/${KEY_NAME}" \
  input=@"${BMAP_OUTPUT_NAME_SHA256}" \
  prehashed=true \
  hash_algorithm=sha2-256 \
  signature_algorithm=pkcs1v15 \
  signature=@"${BMAP_OUTPUT_NAME_SIG_VAULT}"
errorCheck "Failed to verify ${BMAP_OUTPUT_NAME} signature using vault"

# Produce signature compatible with openssl
cat "${IMAGE_OUTPUT_NAME_SIG_VAULT}" | cut -f3 -d: | base64 -d > "${IMAGE_OUTPUT_NAME_SIG}"
errorCheck "Failed to convert ${IMAGE_OUTPUT_NAME} signature"

cat "${BMAP_OUTPUT_NAME_SIG_VAULT}" | cut -f3 -d: | base64 -d > "${BMAP_OUTPUT_NAME_SIG}"
errorCheck "Failed to convert ${BMAP_OUTPUT_NAME} signature"

# upload package
[ ! -z "$AWS_PROFILE" ]
errorCheck "AWS_PROFILE not given"
[ ! -z "$AWS_BUCKET" ]
errorCheck "AWS_BUCKET not given"
aws s3 cp $IMAGE_OUTPUT_NAME s3://$AWS_BUCKET/$IMAGE_OUTPUT_NAME --profile $AWS_PROFILE --acl public-read
aws s3 cp $BMAP_OUTPUT_NAME s3://$AWS_BUCKET/$BMAP_OUTPUT_NAME --profile $AWS_PROFILE --acl public-read

aws s3 cp $IMAGE_OUTPUT_NAME_SIG s3://$AWS_BUCKET/$IMAGE_OUTPUT_NAME_SIG --profile $AWS_PROFILE --acl public-read
aws s3 cp $BMAP_OUTPUT_NAME_SIG s3://$AWS_BUCKET/$BMAP_OUTPUT_NAME_SIG --profile $AWS_PROFILE --acl public-read
