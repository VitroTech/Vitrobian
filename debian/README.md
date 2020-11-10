# Vitrobian

Initial image recipe based on an example from the
[debos-recipes](https://github.com/go-debos/debos-recipes/tree/master/debian/arm64/image-rpi3).

# Building

[godebos/debos](https://github.com/go-debos/debos/tree/master/docker) container is used to
perform the build. First, pull docker image:

```
docker pull godebos/debos
```

Next, make sure virtualization is enabled:

```
ls /dev/kvm
```

If there is no `dev/kvm` device, enable virtualization in your BIOS setup.

Vitrobian image can be build with following command:

```
docker run --rm --interactive --tty --device /dev/kvm \
--user $(id -u) --workdir /recipes \
--mount "type=bind,source=$(pwd),destination=/recipes" \
--security-opt label=disable godebos/debos vitrobian-crystal.yaml
```

# Releasing

```
AWS_PROFILE=<AWS_PROFILE> AWS_BUCKET=<AWS_BUCKET> ./release.sh
```
