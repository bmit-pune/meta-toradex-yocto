SUMMARY = "NVIDIAS tegrastats"
DESCRIPTION = "NVIDIAS tegrastats in a commandline version and one with output to a gtk title bar, gives information about cpu use"
LICENSE = "CLOSED"
PR = "r3"

RDEPENDS_{PN}-gtk = "pango"

SRC_URI =  "file://tegrastats \
            file://tegrastats-gtk \
	    file://Tegrastats-gtk.desktop "

S = "${WORKDIR}"

PACKAGES = "${PN} ${PN}-gtk"

# Inhibit warnings about files being stripped.
# Inhibit warnings about missing DEPENDS, Files are provided in binary form"
WARN_QA_remove = "already-stripped build-deps"
WARN_QA-gtk_remove = "already-stripped build-deps"

do_install() {
    install -d ${D}${bindir}/ ${D}/home/root/Desktop/
    install -m 0755 ${S}/tegrastats* ${D}${bindir}/
    install -m 0755 ${S}/Tegrastats-gtk.desktop ${D}/home/root/Desktop/
}

FILES_${PN}-gtk = " \
	${bindir}/tegrastats-gtk \
	/home/root/Desktop/Tegra* "

FILES_${PN} = "${bindir}/tegrastats"
