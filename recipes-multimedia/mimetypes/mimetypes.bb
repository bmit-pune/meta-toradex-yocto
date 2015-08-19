SUMMARY = "use mimetypes to start a videoplayer"
LICENSE = "MIT"
PR = "r2"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6)"

SRC_URI =  " \
    file://aplay.desktop \
    file://gst-launch.desktop \
    file://mimeapps.list \
    file://COPYING \
"

LIC_FILES_CHKSUM = "file://${WORKDIR}/COPYING;md5=1c3a7fb45253c11c74434676d84fe7dd"

FILES_${PN} += " \
    /home/root/.local/share/applications/* \
"

do_compile () {
}

do_install () {
    install -d ${D}/home/root/.local/share/applications/

    install -m 0644 ${WORKDIR}/*.desktop ${D}/home/root/.local/share/applications/
    install -m 0644 ${WORKDIR}/mimeapps.list ${D}//home/root/.local/share/applications/
}
