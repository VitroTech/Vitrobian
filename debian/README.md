# Vitrobian

Initial image recipe based on an example from the
[debos-recipes](https://github.com/go-debos/debos-recipes/tree/master/debian/arm64/image-rpi3).

# Building

[debos-docker](https://github.com/3mdeb/debos-docker.git) container is used to
perform the build.

Assuming that the `run.sh` script is accessible in the `PATH` as described in the
[Running section of the debos-docker](https://github.com/3mdeb/debos-docker#running),
image can be build with following command:

```
debos-docker vitrobian-crystal.yaml
```

# Releasing

```
AWS_PROFILE=<AWS_PROFILE> AWS_BUCKET=<AWS_BUCKET> ./release.sh
```
