DESCRIPTION = "Userspace tools for MMC/SD devices"
HOMEPAGE = "http://git.kernel.org/cgit/linux/kernel/git/cjb/mmc-utils.git/"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://mmc.c;beginline=1;endline=17;md5=d7747fc87f1eb22b946ef819969503f0"

BRANCH ?= "master"
SRCREV = "eb1cd019c6ad425633a509ab3578e59d5c9ebbc5"

PV = "0.1"

SRC_URI = "git://chromium.googlesource.com/chromiumos/third_party/mmc-utils.git;protocol=https;branch=${BRANCH} \
           file://0001-mmc.h-don-t-include-asm-generic-int-ll64.h.patch"

S = "${WORKDIR}/git"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 mmc ${D}${bindir}
}
