run findfdt
setenv boot_part 2
setenv bootargs "console=ttymxc0,115200n8 video=mxcfb0:dev=hdmi,1920x1080m60,if=RGB24,bpp=32 cma=128M rootfstype=ext4 rootwait panic=10 root=/dev/mmcblk1p${boot_part}"
ext4load mmc ${mmcdev}:${boot_part} 0x13000000 /boot/${fdtfile}
ext4load mmc ${mmcdev}:${boot_part} 0x10800000 /vmlinuz
ext4load mmc ${mmcdev}:${boot_part} 0x14000000 /initrd.img
bootz 0x10800000 0x14000000:${filesize} 0x13000000
