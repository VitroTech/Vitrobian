# Building using Docker container

* Build docker image from source

```
$ docker build -t vitrobian-boot-files .
```

* Run docker container

IMPORTANT: Following docker command should be run from
`Vitrobian/components/boot-files` directory. Also, make sure to pass correct
`-v` flag - `-v $PWD:/home/build`.

```
Vitrobian/components/boot-files$ docker run --rm -it -v $PWD:/home/build vitrobian-boot-files /bin/bash
```

* Inside docker container, run `build.sh` script:

```
(docker)root@36077c70bc38:/home/build# ./build.sh
```

Above script should create `vitro-crystal-boot-files` directory, which should
also be visible outside docker container. Check if it has following content.
If yes, then all boot componenets have been correctly built and docker container
can be closed. Moreover, mentioned directory has been compressed to tarball
`vitro-crystal-boot-files_0.3.0.tar.gz`.

* `vitro-crystal-boot-files` should have following structure:

```
(docker)root@36077c70bc38:/home/build# tree vitro-crystal-boot-files
vitro-crystal-boot-files
`-- boot
    |-- imx6dl-crystal3.dtb
    `-- u-boot
        |-- SPL
        |-- boot.scr
        `-- u-boot.img

2 directories, 4 files
```

    - imx6dl-crystal3.dtb is custom devicetree
    - SPL and u-boot.img are custom U-Boot images
    - boot.scr is custom boot script

`build.sh` script executes comprehensive boot components build. If you wish to
build only specific ones, invoke specific command inside docker container:

* to build U-Boot:

```
(docker)root@36077c70bc38:/home/build# ./build-from-vitro-forks.sh u-boot vitro-crystal-boot-files/boot/u-boot
(...)
  LD      spl/u-boot-spl
  OBJCOPY spl/u-boot-spl-nodtb.bin
  COPY    spl/u-boot-spl.bin
  CFGS    arch/arm/mach-imx/spl_sd.cfg.cfgtmp
  MKIMAGE SPL
  CFGCHK  u-boot.cfg
/home/build

(docker)root@36077c70bc38:/home/build# ls -l vitro-crystal-boot-files/boot/u-boot/
total 372
-rw-r--r-- 1 root root  44032 Nov 30 12:17 SPL
-rw-r--r-- 1 root root 334120 Nov 30 12:17 u-boot.img
```

* to build device tree:

```
(docker)root@36077c70bc38:/home/build# ./build-from-vitro-forks.sh devicetree vitro-crystal-boot-files/boot/
(...)
  DTC     arch/arm/boot/dts/vf610m4-colibri.dtb
  DTC     arch/arm/boot/dts/vf610-cosmic.dtb
  DTC     arch/arm/boot/dts/vf610m4-cosmic.dtb
  DTC     arch/arm/boot/dts/vf610-twr.dtb
  DTC     arch/arm/boot/dts/vf610-zii-dev-rev-b.dtb
  DTC     arch/arm/boot/dts/vf610-zii-dev-rev-c.dtb
/home/build

(docker)root@36077c70bc38:/home/build# ls -l vitro-crystal-boot-files/boot/
total 44
-rw-r--r-- 1 root root 39756 Nov 30 12:18 imx6dl-crystal3.dtb
drwxr-xr-x 2 root root  4096 Nov 30 12:17 u-boot
```

* to build boot script:

```
(docker)root@36077c70bc38:/home/build# mkimage -A arm -O linux -T script -C none -d boot.cmd vitro-crystal-boot-files/boot/u-boot/boot.scr
Image Name:   
Created:      Mon Nov 30 12:19:41 2020
Image Type:   ARM Linux Script (uncompressed)
Data Size:    422 Bytes = 0.41 KiB = 0.00 MiB
Load Address: 00000000
Entry Point:  00000000
Contents:
   Image 0: 414 Bytes = 0.40 KiB = 0.00 MiB
```

# Releasing

```
AWS_PROFILE=<AWS_PROFILE> AWS_BUCKET=<AWS_BUCKET> ./release.sh
```

where `AWS_PROFILE` is profile name from `~/.aws/config`