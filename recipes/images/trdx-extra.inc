#additional packages to include in our Toradex images

# Copy Licenses to image /usr/share/common-licenses, on vybrid for flash size reasons only the manifest
COPY_LIC_MANIFEST = "1"
COPY_LIC_DIRS = "1"
COPY_LIC_DIRS_colibri-vf = "0"

#build some ipk which are needed together with CAN, but do not yet install them
DEPENDS += "canutils libsocketcan iproute2"

#the following builds cross gdb and gdbserver
DEPENDS += "gdb-cross-${TARGET_ARCH}"

#create the file /etc/timestamp
IMAGE_PREPROCESS_COMMAND = "rootfs_update_timestamp"

IMAGE_INSTALL_T20_T30 = " \
    u-boot-toradex-fw-utils \
    gpioconfig \
    tegrastats \
    trdx-nv-binaries \
    trdx-nv-binaries-nv-gstapps \
    trdx-nv-binaries-restricted-codecs \
    usb-rndis-systemd \
    hdmi-hotplug \
    \
    curl \
    file \
    aspell \
    eglinfo-x11 \
    kernel-modules \
"

IMAGE_INSTALL_MACHINE_apalis-t30 = " \
    ${IMAGE_INSTALL_T20_T30} \
    pciutils \
    ptpd \
    iproute2 \
    canutils \
    lvds-ctrl \
    fs-init \
    e2fsprogs \
    e2fsprogs-mke2fs \
    e2fsprogs-tune2fs \
"

IMAGE_INSTALL_MACHINE_colibri-t20 = " \
    ${IMAGE_INSTALL_T20_T30} \
    mtd-utils-ubifs \
"

IMAGE_INSTALL_MACHINE_colibri-t30 = " \
    ${IMAGE_INSTALL_T20_T30} \
    fs-init \
    e2fsprogs \
    e2fsprogs-mke2fs \
    e2fsprogs-tune2fs \
"

#note that the kernel-modules meta package gets installed from
#meta-fsl-arm/conf/machine/include/imx-base.inc
IMAGE_INSTALL_MACHINE_apalis-imx6 = " \
    u-boot-toradex-fsl-fw-utils \
    gpioconfig \
    usb-rndis-systemd \
    gpio-export \
    curl \
    file \
    aspell \
    pciutils \
    ptpd \
    iproute2 \
    canutils \
    fs-init \
    e2fsprogs \
    e2fsprogs-mke2fs \
    e2fsprogs-tune2fs \
    mimetypes \
    eglinfo-x11 \
"

#note that the kernel-modules meta package gets installed from
#meta-fsl-arm/conf/machine/include/imx-base.inc
IMAGE_INSTALL_MACHINE_colibri-imx6 = " \
    u-boot-toradex-fsl-fw-utils \
    usb-rndis-systemd \
    gpio-export \
    curl \
    file \
    aspell \
    ptpd \
    iproute2 \
    canutils \
    fs-init \
    e2fsprogs \
    e2fsprogs-mke2fs \
    e2fsprogs-tune2fs \
    mimetypes \
    eglinfo-x11 \
"

IMAGE_INSTALL_MACHINE_colibri-vf = " \
    u-boot-toradex-fsl-fw-utils \
    libusbg \
    gpioconfig \
    ptpd \
    iproute2 \
    canutils \
    mtd-utils-ubifs \
    mqxboot \
    libmcc \
    mcc-pingpong \
    kernel-module-mcc \
    kernel-modules \
"

IMAGE_INSTALL_MACHINE = ""

IMAGE_INSTALL += " \
    max9526-i2c \
    linux-firmware-ralink \
    \
    alsa-utils \
    alsa-utils-aplay \
    alsa-utils-amixer \
    \
    sqlite3 \
    \
    curl \
    nfs-utils-client \
    openssh-scp \
    openssh-sftp \
    \
    bzip2 \
    gdbserver \
    grep \
    joe \
    minicom \
    ldd \
    lsof \
    mtd-utils \
    udisks \
    dosfstools \
    util-linux-fstrim \
    \
    devmem2 \
    evtest \
    hdparm \
    iperf \
    i2c-tools \
    memtester \
    stress \
    lmbench \
    nbench-byte \
    ethtool \
    \
    ${IMAGE_INSTALL_MACHINE} \
    \
    trdx-oak-sensors \
"
#    openssl-conf 
