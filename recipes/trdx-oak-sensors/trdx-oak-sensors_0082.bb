SUMMARY = "Sample code to access the toradex oak sensors"
LICENSE = "PD"

S="${WORKDIR}/OakLinux_${PV}"

SRC_URI = "http://files.toradex.com/Oak/Linux/OakLinux_${PV}.tar.bz2"

SRC_URI[md5sum] = "cedc87c056f961c15751ee899fb719d5"
SRC_URI[sha256sum] = "69836dfa746422a64f6518cc9e785a7a64ca67d82f5fae0421515a59f4394929"
LIC_FILES_CHKSUM = "file://COPYING;md5=1c3a7fb45253c11c74434676d84fe7dd"

inherit autotools

FILES_${PN} += ""

