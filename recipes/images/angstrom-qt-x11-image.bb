#Angstrom image
SUMMARY = "Image based on qt4-x11-free"

LICENSE = "MIT"

PV = "V2.4"
PR = "r0"

#start of the resulting deployable tarball name
IMAGE_NAME_colibri-t20 = "Colibri_T20_LinuxImage-qt"
IMAGE_NAME_colibri-t30 = "Colibri_T30_LinuxImage-qt"
IMAGE_NAME_apalis-t30 = "Apalis_T30_LinuxImage-qt"
IMAGE_NAME_colibri-pxa = "Colibri_PXA_LinuxImage-qt"
IMAGE_NAME_colibri-imx6 = "Colibri_iMX6_LinuxImage-qt"
IMAGE_NAME_apalis-imx6 = "Apalis_iMX6_LinuxImage-qt"
IMAGE_NAME = "${MACHINE}_LinuxImage-qt"

SYSTEMD_DEFAULT_TARGET = "graphical.target"

#create the deployment directory-tree
require recipes/images/trdx-image-fstype.inc

#remove interfering sysv scripts, connman systemd service
do_mkrmscript () {
    echo "for i in ${IMAGE_ROOTFS}/etc/rc0.d ${IMAGE_ROOTFS}/etc/rc1.d ${IMAGE_ROOTFS}/etc/rc2.d ${IMAGE_ROOTFS}/etc/rc3.d ${IMAGE_ROOTFS}/etc/rc4.d ${IMAGE_ROOTFS}/etc/rc5.d ${IMAGE_ROOTFS}/etc/rc6.d ${IMAGE_ROOTFS}/etc/rcS.d ; do" > ${WORKDIR}/rmscript
    echo "    rm -f \$i/*dropbear \$i/*avahi-daemon \$i/*dbus-1 \$i/*lxdm \$i/*ntpd \$i/*syslog \$i/*ofono \$i/*alsa-state \$i/*networking \$i/*udev-late-mount \$i/*sendsigs \$i/*save-rtc.sh \$i/*umountnfs.sh \$i/*portmap \$i/*umountfs \$i/*halt \$i/*rmnologin.sh \$i/*reboot; rm -f \$i/*banner.sh \$i/*sysfs.sh \$i/*checkroot.sh \$i/*alignment.sh \$i/*mountall.sh \$i/*populate-volatile.sh \$i/*devpts.sh \$i/*hostname.sh \$i/*portmap \$i/*mountnfs.sh \$i/*bootmisc.sh" >> ${WORKDIR}/rmscript
    echo "done" >> ${WORKDIR}/rmscript
    chmod +x ${WORKDIR}/rmscript
    readlink -e ${WORKDIR}/rmscript
    cat ${WORKDIR}/rmscript
}
addtask mkrmscript before do_rootfs

IMAGE_LINGUAS = "en-us"
#IMAGE_LINGUAS = "de-de fr-fr en-gb en-us pt-br es-es kn-in ml-in ta-in"
#ROOTFS_POSTPROCESS_COMMAND += 'install_linguas; '

DISTRO_UPDATE_ALTERNATIVES ??= ""
ROOTFS_PKGMANAGE_PKGS ?= '${@base_conditional("ONLINE_PACKAGE_MANAGEMENT", "none", "", "${ROOTFS_PKGMANAGE} ${DISTRO_UPDATE_ALTERNATIVES}", d)}'

CONMANPKGS ?= "connman connman-systemd connman-plugin-loopback connman-plugin-ethernet connman-plugin-wifi connman-client connman-gnome"
CONMANPKGS_libc-uclibc = ""

DEPENDS += "gst-plugins-good gst-plugins-bad gst-plugins-ugly"

#deploy the OpenGL ES headers to the sysroot
DEPENDS_append_tegra = " nvsamples"

#don't install some id databases
#BAD_RECOMMENDATIONS_append_colibri-vf = " udev-hwdb cpufrequtils "

# this would pull in a large amount of gst-plugins, we only add a selected few
#    gst-plugins-base-meta
#    gst-plugins-good-meta
#    gst-plugins-bad-meta
#    gst-ffmpeg
GSTREAMER = " \
    gstreamer \
    gst-plugins-base \
    gst-plugins-base-alsa \
    gst-plugins-base-audioconvert \
    gst-plugins-base-audioresample \
    gst-plugins-base-audiotestsrc \
    gst-plugins-base-decodebin \
    gst-plugins-base-decodebin2 \
    gst-plugins-base-playbin \
    gst-plugins-base-typefindfunctions \
    gst-plugins-base-ivorbisdec \
    gst-plugins-base-ogg \
    gst-plugins-base-theora \
    gst-plugins-base-videotestsrc \
    gst-plugins-base-vorbis \
    gst-plugins-good-audioparsers \
    gst-plugins-good-autodetect \
    gst-plugins-good-avi \
    gst-plugins-good-deinterlace \
    gst-plugins-good-id3demux \
    gst-plugins-good-isomp4 \
    gst-plugins-good-matroska \
    gst-plugins-good-rtp \
    gst-plugins-good-rtpmanager \
    gst-plugins-good-udp \
    gst-plugins-good-video4linux2 \
    gst-plugins-good-wavenc \
    gst-plugins-good-wavparse \
    gst-plugins-ugly-asf \
"
GSTREAMER_append_tegra3 = " \
    gst-plugins-good-jpeg \
"
GSTREAMER_append_mx6 = " \
    gst-plugins-base-ximagesink \
    gst-plugins-base-xvimagesink \
    gst-plugins-gl \
    gst-fsl-plugin \
    gpu-viv-bin-mx6q-libraries \
"
GSTREAMER_colibri-vf = ""


IMAGE_INSTALL_QT4 = " \
    qt4-x11-free \
    qt4-xmlpatterns \
    libqt3support4 \
    libqtclucene4 \
    libqtcore4 \
    libqtdbus4 \
    libqtgui4 \
    libqthelp4 \
    libqtmultimedia4 \
    libqtnetwork4 \
    libqtscript4 \
    libqtscripttools4 \
    libqtsql4 \
    libqtsvg4 \
    libqttest4 \
    libqtwebkit4 \
    libqtxml4 \
    qt4-plugin-iconengine-svgicon \
    qt4-plugin-imageformat-gif \
    qt4-plugin-imageformat-ico \
    qt4-plugin-imageformat-jpeg \
    qt4-plugin-imageformat-mng \
    qt4-plugin-imageformat-svg \
    qt4-plugin-imageformat-tga \
    qt4-plugin-imageformat-tiff \
    qt4-plugin-phonon-backend-gstreamer \
    qt4-plugin-script-dbus \
    qt4-plugin-sqldriver-sqlite \
    qt4-demos \
    qt4-x11-free-systemd \
    qt4-examples \
    qt4-assistant \
    icu \
"

IMAGE_INSTALL += " \
    ${IMAGE_INSTALL_QT4} \
    \
    xdg-utils \
    xvinfo \
    \
    initscripts \
    libgsf \
    libwnck \
    libxres \
    makedevs \
    mime-support \
    xcursor-transparent-theme \
    zeroconf \
    angstrom-packagegroup-boot \
    packagegroup-basic \
    udev-extra-rules \
    ${CONMANPKGS} \
    ${ROOTFS_PKGMANAGE_PKGS} \
    timestamp-service \
    packagegroup-base-extended \
    ${XSERVER} \
    xserver-common \
    xserver-xorg-extension-dbe \
    xserver-xorg-extension-extmod \
    xauth \
    xhost \
    xset \
    setxkbmap \
    \
    xrdb \
    xorg-minimal-fonts xserver-xorg-multimedia-modules xserver-xorg-utils \
    scrot \
    unclutter \
    \
    libxdamage libxvmc libxinerama \
    libxcursor \
    \
    bash \
    \
    ${GSTREAMER} \
    v4l-utils \
    libpcre \
    libpcreposix \
    libxcomposite \
    alsa-states \
"

require recipes/images/trdx-extra.inc

IMAGE_DEV_MANAGER   = "udev"
IMAGE_INIT_MANAGER  = "systemd"
IMAGE_INITSCRIPTS   = " "
IMAGE_LOGIN_MANAGER = "busybox shadow"

export IMAGE_BASENAME = "qt-image"

inherit core-image
