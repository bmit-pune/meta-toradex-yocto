SUMMARY = "MultiCore Communication Ping-Pong Demo Application"
SECTION = "examples"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c49712341497d0b5f2e40c30dff2af9d"
PR = "r0"

SRC_URI = " \
	http://repository.timesys.com/buildsources/m/mcc-pingpong/mcc-pingpong-${PV}/mcc-pingpong-${PV}.tar.bz2 \
	file://update-mcc_free_buffer-call.patch \
	file://makefile-use-libs.patch \
"

SRC_URI[md5sum] = "a03417c37f97849baa794e37d88e0cd2"
SRC_URI[sha256sum] = "ad25a15f34eb758b7896d327a28ef884e2ab04851cff42f059b32dc63e42704b"

S = "${WORKDIR}/mcc-pingpong-${PV}"

CFLAGS += "-I${STAGING_KERNEL_DIR}/include"

DEPENDS = "libmcc"

do_install (){
	oe_runmake DESTDIR=${D} install
}

COMPATIBLE_MACHINE = "(vf60)"
