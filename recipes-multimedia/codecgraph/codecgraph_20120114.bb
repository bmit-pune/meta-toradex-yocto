SECTION = "multimedia"
SUMMARY = "Tool to generate a graph of HDA codec config"
DESCRIPTION = "Codecgraph is a tool to generate a graph based on the ALSA description of a High Definition Audio codec."
HOMEPAGE = "http://helllabs.org/codecgraph/"
LICENSE ="GPLv2+"
RDEPENDS_${PN} = "python graphviz"

SRC_URI = "http://helllabs.org/codecgraph/codecgraph-${PV}.tar.gz"
LIC_FILES_CHKSUM = "file://COPYING;md5=8ca43cbc842c2336e835926c2166c28b"
SRC_URI[md5sum] = "30bb1afeda28b7e9b7f36e3b5b98a869"
SRC_URI[sha256sum] = "24dca78c6a8cf894385df304d29f348d48868000d5ffbd03bf12c5b4f9805106"

S = "${WORKDIR}/codecgraph-${PV}"

PR = "r1"

do_install() {
    install -d ${D}/${bindir} ${D}/${mandir}/man1
    install -m755 -D codecgraph ${D}/${bindir}/codecgraph
    install -m755 -D codecgraph.py ${D}/${bindir}/codecgraph.py
    install -m644 -D codecgraph.1 ${D}/${mandir}/man1/codecgraph.1
}