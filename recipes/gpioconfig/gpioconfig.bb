SUMMARY = "GPIOConfig tool for Toradex Modules"
SECTION = "base"
LICENSE = "CLOSED"
PR = "r3"

PACKAGE_ARCH = "${MACHINE_ARCH}"

DEPENDS = "gtk+"
RDEPENDS_{PN} = "gtk+"

SRC_URI =  "file://GPIOConfig"
SRC_URI += "file://GPIOConfig.desktop"
SRC_URI += "file://GPIOConfig.png"

PACKAGES = "${PN}"

#no gnu_hash in binaries, skip QA dev-so for this package
#we have symlinks ending in .so, skip QA ldflags for this package
#inhibit warnings about files being stripped
INSANE_SKIP_${PN} = "ldflags already-stripped"

# just don't do any configuring
do_configure() {
}

do_install() {
        install -d ${D}/${bindir}
	install -d ${D}/${datadir}/applications
	install -d ${D}/${datadir}/pixmaps
        install -m 755 ${WORKDIR}/GPIOConfig ${D}/${bindir}
	install -m 644 ${WORKDIR}/GPIOConfig.desktop ${D}/${datadir}/applications
        install -m 644 ${WORKDIR}/GPIOConfig.png ${D}/${datadir}/pixmaps/GPIOConfig.png
}

pkg_postinst_${PN}() {
	mkdir -p ${base_prefix}/home/root/Desktop
	cp ${datadir}/applications/GPIOConfig.desktop ${base_prefix}/home/root/Desktop/
}

pkg_postremove_${PN}() {
        rm -f ${base_prefix}/home/Desktop/GPIOConfig.desktop
}



