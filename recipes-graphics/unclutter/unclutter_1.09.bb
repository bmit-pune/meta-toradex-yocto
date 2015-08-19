SUMMARY = "Hides the cursor after inactivity"
LICENSE = "PD"

DEPENDS = "virtual/xserver"
PR = "r0"

S = "${WORKDIR}/unclutter-${PV}"

SRC_URI = "${SOURCEFORGE_MIRROR}/unclutter/unclutter-${PV}.tar.gz \
	file://cross-compile.patch \
"
LIC_FILES_CHKSUM = "file://README;md5=7c9b6681ac4b35194de7d5f3585702b6"
SRC_URI[md5sum] = "8c4464367b2db1d15fe36a8752e917c8"
SRC_URI[sha256sum] = "3a53575fe2a75a34bc9a2b0ad92ee0f8a7dbedc05d8783f191c500060a40a9bd"

do_install () {
    install -d ${D}${bindir}/ ${D}${mandir}/man1
    install -m 0755 ${S}/unclutter ${D}${bindir}/
    install -m 0644 ${S}/unclutter.man ${D}${mandir}/man1/unclutter.1
}
