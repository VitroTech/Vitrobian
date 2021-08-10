# Vitrobian

Initial image recipe based on an example from the
[debos-recipes](https://github.com/go-debos/debos-recipes/tree/master/debian/arm64/image-rpi3).

# Building

[godebos/debos](https://github.com/go-debos/debos/tree/master/docker) container
is used to perform the build. First, pull docker image:

```
$ docker pull godebos/debos
```

Next, make sure virtualization is enabled:

```
$ ls /dev/kvm
```

> If there is no `dev/kvm` device, enable virtualization in your BIOS setup.

Vitrobian image can be build with following command:

```
docker run --rm --interactive --tty --device /dev/kvm \
--user $(id -u) --workdir /recipes \
--mount "type=bind,source=$(pwd),destination=/recipes" \
--group-add $(getent group kvm | cut -d: -f3) \
--security-opt label=disable godebos/debos vitrobian-crystal.yaml
```

# Known issues

There is known issue with platform booting. Sometimes boot hangs at `Begin:
Running /scripts/local-block ... done.` stage. It is caused by
`pfuze100-regulator` initialization issue. In bootlog it can be observed with
following entries:

```
[   11.766521] pfuze100-regulator 2-0008: unrecognized pfuze chip ID!
[   11.772868] pfuze100-regulator: probe of 2-0008 failed with error -110
```

If platform didn't boot, simply restart it via restart button or directly by
unplugging and plugging power supply. We have notice that unsuccessful boot
happens once every 10-15 boots.

# Releasing

```
AWS_PROFILE=<AWS_PROFILE> AWS_BUCKET=<AWS_BUCKET> ./release.sh
```
