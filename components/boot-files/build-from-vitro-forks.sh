#!/bin/bash

SCRIPT_ROOT_DIR="$(dirname $(readlink -f $0))"

TOOLCHAIN_DIR_NAME="gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf"
TOOLCHAIN_ROOT_DIR="${SCRIPT_ROOT_DIR}/${TOOLCHAIN_DIR_NAME}"
TOOLCHAIN_XZ="${TOOLCHAIN_ROOT_DIR}.tar.xz"
TOOLCHAIN_BIN_DIR="${TOOLCHAIN_ROOT_DIR}/bin"
TOOLCHAIN_XZ_NAME="${TOOLCHAIN_DIR_NAME}.tar.xz"
TOOLCHAIN_URL="https://releases.linaro.org/components/toolchain/binaries/6.4-2018.05/arm-linux-gnueabihf/${TOOLCHAIN_XZ_NAME}"
TOOLCHAIN_SHA256="5594e51e45913e50e5d67f2445c639d4fb6d91ff7d6f3bf2267cb961d99ffa89"

UBOOT_DIR="${SCRIPT_ROOT_DIR}/u-boot"
UBOOT_BRANCH="vitrobian-v2018.03"
UBOOT_DEFCONFIG="crystal_defconfig"
UBOOT_REMOTE="https://github.com/VitroTech/u-boot.git"
UBOOT_REV="c2938b2b4ad69ff589f787094183b453a50133fd"

LINUX_DIR="${SCRIPT_ROOT_DIR}/linux"
LINUX_BRANCH="vitrobian-v4.14"
LINUX_DEFCONFIG="imx_v6_v7_defconfig"
LINUX_REMOTE="https://github.com/VitroTech/linux.git"
LINUX_DTB="imx6dl-crystal3.dtb"
LINUX_REV="a7837a71bcd5fd5b62a0840bde0e7789a8f0cbfc"

THREADS="-j8"

function usage {
cat <<EOF

Usage: ./$(basename ${0}) command destination

    Commands:
        u-boot       build U-Boot
        devicetree   build devicetree

    Parameters:
        destination  target directory to which the output files will be deployed
EOF
exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

COMMAND="$1"
DESTINATION="$(readlink -f $2)"

if [ ! -d ${DESTINATION} ]; then
    echo "${DESTINATION} directory does not exist"
    exit 1
fi

function errChk {
    ERR_CODE="${?}"
    if [ "${ERR_CODE}" -ne 0  ]; then
        echo "ERROR ($ERR_CODE): ${1}"
        exit 1
    fi
}

function setupToolchain {
    DOWNLOAD="false"
    UNPACK="false"
    # assume toolchain is present if gcc is there
    if [ ! -f "${TOOLCHAIN_BIN_DIR}/arm-linux-gnueabihf-gcc" ]; then
        if [ ! -f "${TOOLCHAIN_XZ}" ]; then
            DOWNLOAD="true"
            UNPACK="true"
        else
            SHA256="$(sha256sum ${TOOLCHAIN_XZ} | cut -f 1 -d ' ')"
            if [ "$SHA256" != "$TOOLCHAIN_SHA256" ]; then
                DOWNLOAD="true"
                UNPACK="true"
            fi
        fi
    fi

    if [ "${DOWNLOAD}" = "true" ]; then
        wget -P ${SCRIPT_ROOT_DIR} ${TOOLCHAIN_URL}
        errChk "Failed to download toolchain"
    fi

    if [ "${UNPACK}" ]; then
        tar xf ${TOOLCHAIN_XZ}
        errChk "Failed to unpack toolchain"
    fi

    export PATH="${PATH}:${TOOLCHAIN_BIN_DIR}"
    export ARCH="arm"
    export CROSS_COMPILE="arm-linux-gnueabihf-"
}

function fetchUboot {
    if [ -d ${UBOOT_DIR} ]; then
        if pushd ${UBOOT_DIR}; then
            git checkout -f .
            errChk "Failed to checkout"
            REV="$(git rev-parse HEAD)"
            popd
        fi
    fi

    if [ "${REV}" = "${UBOOT_REV}" ]; then
        echo "U-Boot already fetched"
    else
        rm -rf ${UBOOT_DIR}
        git clone --branch ${UBOOT_BRANCH} --depth 1 --single-branch ${UBOOT_REMOTE} ${UBOOT_DIR}
        errChk "Failed to fetch U-Boot"
    fi
}

function fetchLinux {
    if [ -d ${LINUX_DIR} ]; then
        if pushd ${LINUX_DIR}; then
            git checkout -f .
            errChk "Failed to checkout"
            REV="$(git rev-parse HEAD)"
            popd
        fi
    fi

    if [ "${REV}" = "${LINUX_REV}" ]; then
        echo "Linux already fetched"
    else
        rm -rf ${LINUX_DIR}
        git clone --branch ${LINUX_BRANCH} --depth 1 --single-branch ${LINUX_REMOTE} ${LINUX_DIR}
        errChk "Failed to fetch Linux"
    fi
}

function buildUboot {
    if pushd ${UBOOT_DIR}; then
        make distclean
        errChk "Linux make distclean failed"
        make ${UBOOT_DEFCONFIG}
        errChk "U-Boot defconfig failed"
        make ${THREADS}
        errChk "U-Boot build failed"
        cp u-boot.img SPL ${DESTINATION}
        errChk "Failed to copy u-boot.img and SPL into ${DESTINATION}"
        popd
    fi
}

function buildDevicetree {
    if pushd ${LINUX_DIR}; then
        make distclean
        errChk "Linux make distclean failed"
        make ${LINUX_DEFCONFIG}
        errChk "Linux defconfig failed"
        make ${THREADS} dtbs
        cp arch/arm/boot/dts/${LINUX_DTB} ${DESTINATION}
        errChk "Failed to copy ${LINUX_DTB} to ${DESTINATION}"
        popd
    fi
}

case "${COMMAND}" in
    "u-boot")
        setupToolchain
        fetchUboot
        buildUboot
        ;;
    "devicetree")
        setupToolchain
        fetchLinux
        buildDevicetree
        ;;
    *)
        echo "Invalid command: ${COMMAND}"
        usage
        ;;
esac
