# Vitrobian

`Vitrobian` is basically a `Debian` image with the modifications necessary to
support the [Vitro Crystal](https://vitro.io/vitro-crystal.html) platform.

## Usage

### Download image

The latest, pre-build image can be downloaded from the
[following link](https://s3-eu-west-1.amazonaws.com/prod-vitrobian-releases/vitrobian_0.2.0.img.gz)

### Image flashing

#### GUI

Take a look at the [etcher](https://etcher.io/)

#### CLI

```
gzip -cdk vitrobian_0.2.0.img.gz | sudo dd of=/dev/sdX bs=16M status=progress
```

Replacing `sdX` with the descriptor of the block device corresponding to the
`SD card`. For instance:

```
gzip -cdk vitrobian_0.2.0.img.gz | sudo dd of=/dev/sdc bs=16M status=progress
```

#### LOG IN

```
Login: user
Password: user
```

## Building / Development
The `Debian` image is assembled using the
[debos](https://github.com/go-debos/debos) utility, which uses the `Debian`
package feed beneath. Stuff not available in official `Debian` packages will be
built from sources and then downloaded into the final image.

## Repository tree description

```
.
├── components
│   └── boot-files
├── debian
│   ├── debimage-crystal.yaml
│   ├── networkd
│   ├── README.md
│   ├── setup-networking.sh
│   ├── setup-user.sh
├── README.md
└── VERSION
```

### `components` directory

This contains scripts for building all the prerequisites which needs to be
prepared prior to the image assembly.

### `boot-files` directory

It contains scripts for building `U-Boot` and `Linux devicetree` which support
`Vitro Crystal` board. Built binaries are released and uploaded to the `AWS S3`
bucket. They can be downloaded later by anyone who is performing the image
build.

## debian

This contains `debos YAML recipe` as well as scripts and overlay configuration
files which are used during the image assembly phase.

In order to build the `Vitrobian` image, refer to the
[README in debian directory](debian/README.md)
