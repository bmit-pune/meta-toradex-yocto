#create the deployment directory-tree

BURNFLASH := "${THISDIR}/files/${MACHINE}"
IMAGE_ROOTFS = "${WORKDIR}/${IMAGE_NAME}${PV}/rootfs"

U_BOOT_EXT = "bin"
U_BOOT_EXT_mx6 = "imx"
U_BOOT_EXT_vf = "imx"
U_BOOT_SYMLINK = "u-boot-${MACHINE}.${U_BOOT_EXT}"
U_BOOT_SYMLINK_tegra = "u-boot-dtb-tegra-${MACHINE}.${U_BOOT_EXT}"
U_BOOT_BINARY = "u-boot.${U_BOOT_EXT}"
U_BOOT_BINARY_tegra = "u-boot-dtb-tegra.${U_BOOT_EXT}"

#we need some native tools for deployment
DEPENDS_append_mx6 = " imx-loader-native"
#FIXME: 32-bit tegrarcm built on F20 does not run on 64-bit F20 even with properly installed 32-bit libs!
DEPENDS_append_tegra = " cbootimage-native tegrarcm-native"
DEPENDS_append_tegra2 = " mtd-utils-native"
DEPENDS_append_vf = " mtd-utils-native imx-loader-native"
#we need mkimage to produce the U-Boot scripts
DEPENDS_append = " u-boot-mkimage-native"

imagedeploytools() {
    # default to nothing to deploy
    :
}

imagedeploytools_append_mx6() {
    IMAGE_ROOT="${IMAGE_ROOTFS}/../imx_flash/"
    rm -f ${IMAGE_ROOT}/imx_flash/imx_usb ${IMAGE_ROOT}/imx_flash/*.conf
    mkdir -p ${IMAGE_ROOT}

    # add imx-loader and its configuration files
    cp ${STAGING_BINDIR_NATIVE}/imx_usb ${IMAGE_ROOT}/
    ${BUILD_STRIP} ${IMAGE_ROOT}/imx_usb
    cp ${STAGING_ETCDIR_NATIVE}/imx-loader.d/imx_usb.conf ${IMAGE_ROOT}/
    cp ${STAGING_ETCDIR_NATIVE}/imx-loader.d/mx6_usb_work.conf ${IMAGE_ROOT}/
}

imagedeploytools_append_tegra() {
    IMAGE_ROOT="${IMAGE_ROOTFS}/../tegra-uboot-flasher/"
    mkdir -p ${IMAGE_ROOT}

    # add cbootimage and tegrarcm
    cp ${STAGING_BINDIR_NATIVE}/cbootimage ${IMAGE_ROOT}/
    cp ${STAGING_BINDIR_NATIVE}/tegrarcm ${IMAGE_ROOT}/
    ${BUILD_STRIP} ${IMAGE_ROOT}/cbootimage
    ${BUILD_STRIP} ${IMAGE_ROOT}/tegrarcm
}

imagedeploytools_append_tegra2() {
    # add the mkfs.ubifs binary
    cp ${STAGING_DIR_NATIVE}/usr/sbin/mkfs.ubifs ${IMAGE_ROOT}/
    ${BUILD_STRIP} ${IMAGE_ROOT}/mkfs.ubifs
}

imagedeploytools_append_vf() {
    IMAGE_ROOT="${IMAGE_ROOTFS}/../vf_flash/"
    rm -f ${IMAGE_ROOT}/mkfs.ubifs  ${IMAGE_ROOT}/imx_uart
    mkdir -p ${IMAGE_ROOT}

    # add the mkfs.ubifs binary
    cp ${STAGING_DIR_NATIVE}/usr/sbin/mkfs.ubifs ${IMAGE_ROOT}/
    ${BUILD_STRIP} ${IMAGE_ROOT}/mkfs.ubifs

    # add imx-loader and its configuration files
    cp ${STAGING_BINDIR_NATIVE}/imx_uart ${IMAGE_ROOT}/
    ${BUILD_STRIP} ${IMAGE_ROOT}/imx_uart*
    cp ${STAGING_ETCDIR_NATIVE}/imx-loader.d/vybrid_usb_work.conf ${IMAGE_ROOT}/
}

imagedeploy_kernel() {
    # put kernel, device-tree into the bin directories, remove the kernel/dtb from the rootfs/boot
    rm -f ${IMAGE_ROOTFS}/boot/uImage* ${IMAGE_ROOTFS}/boot/*.dtb
    cp -pP ${DEPLOY_DIR_IMAGE}/uImage* ${IMAGE_ROOTFS}/../${MACHINE}_bin/
    ls ${DEPLOY_DIR_IMAGE}/*.dtb 2> /dev/null && cp -pP ${DEPLOY_DIR_IMAGE}/*.dtb ${IMAGE_ROOTFS}/../${MACHINE}_bin/
    mv ${IMAGE_ROOTFS}/../${MACHINE}_bin/uImage-${MACHINE}.bin ${IMAGE_ROOTFS}/../${MACHINE}_bin/uImage
}

imagedeploy_kernel_tegra2() {
    # Do nothing, we use the kernel from /boot inside root fs
    :
}

imagedeploy_kernel_vf() {
    # Do nothing, we use the kernel from /boot inside root fs
    :
}

fakeroot do_imagedeploy() {
    cd ${WORKDIR}
    cp -pLr ${BURNFLASH}/* ${IMAGE_NAME}${PV}/

    cd ${IMAGE_NAME}${PV}/${MACHINE}_bin
    ./mk-u-boot-scripts.sh
    cd ${WORKDIR}

    imagedeploy_kernel

    cp -pP ${DEPLOY_DIR_IMAGE}/u-boot* ${IMAGE_ROOTFS}/../${MACHINE}_bin/
    rm -f ${IMAGE_ROOTFS}/../${MACHINE}_bin/u-boot-hsmmc-${MACHINE}.${U_BOOT_EXT}
    mv ${IMAGE_ROOTFS}/../${MACHINE}_bin/${U_BOOT_SYMLINK} ${IMAGE_ROOTFS}/../${MACHINE}_bin/${U_BOOT_BINARY}

    # add the rootfs version to the welcome banner
    echo "${IMAGE_NAME}${PV}_${DATE}" >> ${IMAGE_ROOTFS}/etc/issue
    echo "" >> ${IMAGE_ROOTFS}/etc/issue

    # add additional tools if required
    imagedeploytools

    # remove intermediate file rootfs.lock
    rm -f ${IMAGE_NAME}${PV}/rootfs.lock

    #create tarball
    DATE=`date +%Y%m%d`
    tar -cjf ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}${PV}_${DATE}.tar.bz2 ${IMAGE_NAME}${PV}
}

addtask imagedeploy after do_rootfs before do_build
