#!/bin/sh

adduser --gecos user \
  --disabled-password \
  --shell /bin/bash \
  user
adduser user sudo
echo "user:user" | chpasswd
sudo adduser --system ggc_user
sudo addgroup --system ggc_group
