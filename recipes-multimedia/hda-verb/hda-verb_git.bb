SECTION = "multimedia"
SUMMARY = "hda-verb sendS HD-audio commands to ALSA HDA devices"
HOMEPAGE = ""
LICENSE ="GPLv2+"
RDEPENDS_${PN} = ""

SRCREV = "4bf54c5003af304e9da8ef40475a481086d80d85"
SRC_URI = "git://git.alsa-project.org/alsa-tools.git;protocol=git"
LIC_FILES_CHKSUM = "file://hda-verb.c;beginline=7;endline=7;md5=8ede3f4055a5dda3b35bdb0d454bc4cc"

S = "${WORKDIR}/git/hda-verb"

PR = "r1"

inherit autotools
