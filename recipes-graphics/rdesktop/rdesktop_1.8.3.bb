DESCRIPTION-${PN}-client = "A remote desktop protocol client"
HOMEPAGE = "http://www.rdesktop.org/"
SECTION = "utils"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=f27defe1e96c2e1ecd4e0c9be8967949"

require rdesktop.inc

PR = "${INC_PR}.3"

inherit autotools

EXTRA_OECONF = "--disable-credssp --with-openssl=${STAGING_EXECPREFIXDIR} "

SRC_URI[md5sum] = "86e8b368a7c715e74ded92e0d7912dc5"
SRC_URI[sha256sum] = "88b20156b34eff5f1b453f7c724e0a3ff9370a599e69c01dc2bf0b5e650eece4"
