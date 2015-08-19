DESCRIPTION = "Rdesktop rdp client for X"
HOMEPAGE = "http://www.rdesktop.org"
DEPENDS = "virtual/libx11 openssl pcsc-lite"
SECTION = "x11/network"
LICENSE = "GPL"

INC_PR = "r2"

SRC_URI  = "${SOURCEFORGE_MIRROR}/rdesktop/rdesktop-${PV}.tar.gz"
SRC_URI += "file://add_ioctl_serial_get_properties.patch"