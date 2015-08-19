SUMMARY = "spidev userspace driver for a Maxim MAX9526"
LICENSE = "CLOSED"

DEPENDS = "gtk+"
PR = "r1"

S = "${WORKDIR}"

SRC_URI="file://max9526-gtk_${PV}.tar.bz2"

do_install () {
    install -d ${D}/${bindir} ${D}/${datadir}/max9526-gtk
    install -m 0755 ${S}/max9526-gtk ${D}/${bindir}/
    install -m 0644 ${S}/max9526.glade ${D}/${datadir}/max9526-gtk/
}
