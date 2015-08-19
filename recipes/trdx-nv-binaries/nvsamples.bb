SECTION = "graphical/utils"
SUMMARY = "Nvidia samples for OpenGL ES, OpenGL ES  headers"
LICENSE = "CLOSED"
DEPENDS = "trdx-nv-binaries"
RDEPENDS_{PN} = "trdx-nv-binaries"

PR = "r1"

PARALLEL_MAKE = ""

SRC_URI = "http://developer.toradex.com/files/toradex-dev/uploads/media/Colibri/Linux/Samples/nvsamples.tar.bz2 \
           file://nvsamples-oe.patch \
           file://nvsamples-no-binary-shaders.patch \
           file://nvsamples-hardfp.patch \
"

S = "${WORKDIR}/nvsamples"

SRC_URI[md5sum] = "240b0beb0056dde2e6ac1538dc8b6684"
SRC_URI[sha256sum] = "2638beea80fd85fdc5f9443e6959c210e275e627f662266cd404ce7c68b0806d"

#no gnu_hash in NVIDIA binaries, skip QA for this package
INSANE_SKIP_${PN} = "dev-so ldflags"

FILES_${PN} += " \
    /home/root/textures/* \
    /home/root/shaders/* \
"

do_compile () {
    cd ${S}/samples/tools/nvtexfont2
    oe_runmake clean
    oe_runmake WORKDIR=${WORKDIR}
    ln -sf ../samples/tools/nvtexfont2/libnvtexfont2.a ${S}/lib-target/

    cd ${S}/samples/tools/nvgl2demo_common
    oe_runmake clean
    oe_runmake WORKDIR=${WORKDIR}
    ln -sf ../samples/tools/nvgl2demo_common/libnvgl2demo_common.a ${S}/lib-target/

    cd ${S}/samples/opengles2
    oe_runmake clean
    oe_runmake WORKDIR=${WORKDIR}
}

do_install () {
    # install the sample code
    install -d ${D}${bindir}
    install -d ${D}/home/root/textures
    install -d ${D}/home/root/shaders
    install -m 0755 ${S}/samples/opengles2/ctree/ctree ${D}${bindir}
    install -m 0644 ${S}/samples/opengles2/ctree/textures/* ${D}/home/root/textures
    install -m 0644 ${S}/samples/opengles2/ctree/*.glsl? ${D}/home/root/shaders
    install -m 0755 ${S}/samples/opengles2/bubble/bubble ${D}${bindir}
    install -m 0644 ${S}/samples/opengles2/bubble/textures/* ${D}/home/root/textures
    install -m 0644 ${S}/samples/opengles2/bubble/*.glsl? ${D}/home/root/shaders
    install -m 0755 ${S}/samples/opengles2/gears/gears ${D}${bindir}
    install -m 0644 ${S}/samples/opengles2/gears/*.glsl? ${D}/home/root/shaders
}
