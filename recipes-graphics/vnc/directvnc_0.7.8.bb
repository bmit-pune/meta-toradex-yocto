SUMMARY = "Provides a very thin VNC client for unix framebuffer systems"
HOMEPAGE = "http://drinkmilk.github.com/directvnc/"
SECTION = "utils"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=cbbd794e2a0a289b9dfcc9f513d1996e"

DEPENDS = "zlib libpng jpeg directfb xproto"

SRC_URI = "https://github.com/downloads/drinkmilk/directvnc/directvnc-${PV}.tar.gz"
SRC_URI[md5sum] = "063f9d98956006f230dcbc05f822525b"
SRC_URI[sha256sum] = "07d6109aef5bba2df86f0dd658be7ed9d828801be0878eba3d32f041189d3330"

inherit autotools
