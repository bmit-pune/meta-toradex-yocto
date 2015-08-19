SUMMARY = "A lightweight VNC viewer"
HOMEPAGE = "http://www.tightvnc.com/"
SECTION = "utils"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://../LICENCE.TXT;md5=75b02c2872421380bbd47781d2bd75d3"

DEPENDS = "virtual/libx11 zlib libxmu libxaw jpeg libxt libxext libxmu"

PR = "r2"

SRC_URI = "${SOURCEFORGE_MIRROR}/vnc-tight/tightvnc-${PV}_unixsrc.tar.bz2 \
           file://Makefile \
           file://Vncviewer"

S = "${WORKDIR}/vnc_unixsrc/vncviewer/"

PACKAGES = "${PN}-viewer-dbg ${PN}-viewer"
FILES_${PN}-viewer-dbg = "${bindir}/.debug"
FILES_${PN}-viewer = "${bindir}/${PN}viewer ${sysconfdir}"

do_compile () {
	install ${WORKDIR}/Makefile ${S}
	oe_runmake
}

do_install () {
	install -d ${D}${bindir}
	install ${PN}viewer ${D}${bindir}
	install -d ${D}${sysconfdir}/X11/app-defaults
	install -m 644 ${WORKDIR}/Vncviewer ${D}${sysconfdir}/X11/app-defaults/Vncviewer
}

pkg_postinst_${PN}-viewer () {
        update-alternatives --install ${bindir}/vncviewer vncviewer tightvncviewer 100
}


pkg_prerm_${PN}-viewer () {
        update-alternatives --remove ${bindir}/vncviewer vncviewer tightvncviewer 100
}

SRC_URI[md5sum] = "397b35faad32d5246b6d44b142f8304f"
SRC_URI[sha256sum] = "f48c70fea08d03744ae18df6b1499976362f16934eda3275cead87baad585c0d"
