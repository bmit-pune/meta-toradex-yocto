SUMMARY = "CLI spidev userspace driver for a Maxim MAX9526"
LICENSE = "CLOSED"

DEPENDS = ""
PR = "r1"

S = "${WORKDIR}"

SRC_URI="file://max9526-i2c_${PV}.tar.bz2"

do_install () {
    install -d ${D}/${bindir}
    install -m 0755 ${S}/max9526-i2c ${D}/${bindir}/
}
