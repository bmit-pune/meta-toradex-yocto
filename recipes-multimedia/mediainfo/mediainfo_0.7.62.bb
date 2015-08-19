HOMEPAGE="mediainfo.sourceforge.net"
SUMMARY = "Mediainfo is a tool to analyze multimedia files"
LICENSE = "GPLv2_modified"

inherit autotools

SRC_URI="http://mediaarea.net/download/binary/mediainfo/0.7.62/MediaInfo_CLI_${PV}_GNU_FromSource.tar.bz2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/MediaInfo_CLI_GNU_FromSource/MediaInfo/License.html;md5=7f3735d23c6ef724bbd1475e4f82edcf"

SRC_URI[md5sum] = "ba10422974111fdff5cf1bb38410c9a1"
SRC_URI[sha256sum] = "ecdde190c9f02ab26769e590314c4841a1c182e8488f1ad8584bdfb374562564"

S = "${WORKDIR}/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI/"

do_configure () {
    #build zenlib
    cd ${WORKDIR}/MediaInfo_CLI_GNU_FromSource/ZenLib/Project/GNU/Library/
    my_runconf
    oe_runmake

    #build media info lib
    cd ${WORKDIR}/MediaInfo_CLI_GNU_FromSource/MediaInfoLib/Project/GNU/Library/
    my_runconf
    oe_runmake

    #build media info
    cd ${S}
    oe_runconf
}

do_install_prepend () {
    #install media info
    cd ${S}
}

my_runconf() {
    cfgscript="./configure"
    if [ -x "$cfgscript" ] ; then
        bbnote "Running $cfgscript --build=${BUILD_SYS} --host=${HOST_SYS} --target=${TARGET_SYS} --prefix=${prefix} --exec_prefix=${exec_prefix} --bindir=${bindir} --sbindir=${sbindir} --libexecdir=${libexecdir} --datadir={datadir} --sysconfdir=${sysconfdir} --sharedstatedir=${sharedstatedir} --localstatedir=${localstatedir} --libdir=${libdir} --includedir=${includedir} --oldincludedir=${oldincludedir} --infodir=${infodir} --mandir=${mandir} --disable-silent-rules --disable-dependency-tracking --with-libtool-sysroot=/home/tegradev/oe-core/build/out-eglibc/sysroots/colibri-t20 $@"
        set +e
        ${CACHED_CONFIGUREVARS} $cfgscript --build=${BUILD_SYS} --host=${HOST_SYS} --target=${TARGET_SYS} --prefix=${prefix} --exec_prefix=${exec_prefix} --bindir=${bindir} --sbindir=${sbindir} --libexecdir=${libexecdir} --datadir=${datadir} --sysconfdir=${sysconfdir} --sharedstatedir=${sharedstatedir} --localstatedir=${localstatedir} --libdir=${libdir} --includedir=${includedir} --oldincludedir=${oldincludedir} --infodir=${infodir} --mandir=${mandir} --disable-silent-rules --disable-dependency-tracking ${@append_libtool_sysroot(d)} $@
        if [ "$?" != "0" ]; then
            echo "Configure failed. The contents of all config.log files follows to aid debugging"
            find /home/tegradev/oe-core/build/out-eglibc/work/armv7ahf-vfp-angstrom-linux-gnueabi/mediainfo-0.7.62-r0/mediainfo-0.7.62 -name config.log -print -exec cat {} \;
            bbfatal "oe_runconf failed"
        fi
        set -e
    else
        bbfatal "no configure script found at $cfgscript"
    fi
}

