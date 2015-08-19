SUMMARY = "USB/UART loader for i.MX51/53/6x and Vybrid"
SECTION = "base"
HOMEPAGE = "https://github.com/boundarydevices/imx_usb_loader"
LICENSE = "LGPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

DEPENDS = "libusb1-native"

SRCREV = "09377bd5b8d04d4b20ef70bb0c56cf3de4500746"
SRC_URI = "git://github.com/toradex/imx_loader.git;protocol=git;branch=master"

S = "${WORKDIR}/git/"

PR = "r1"

#we want imx_usb binary to run on a 32-bit architecture, on x86_64 this requires the 32-bit compatibility libs
EXTRA_OEMAKE_class-native = "CC='${CC} -m32' CXX='${CXX} -m32'"

BBCLASSEXTEND = "native"

do_install () {
    oe_runmake DESTDIR=${D} install
}
