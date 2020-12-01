FROM debian:stable-20201117-slim as build
WORKDIR /home/build
COPY . .

RUN apt-get update && apt-get install -y \
     wget \
     xz-utils \
     build-essential \
     make \
     git \
     bc \
     u-boot-tools \
     tree