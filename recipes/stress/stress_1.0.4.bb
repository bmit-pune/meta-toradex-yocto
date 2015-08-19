# stress .bb build file
# Copyright (C) 2006, Advanced Micro Devices, Inc.  All Rights Reserved
# Released under the MIT license (see /COPYING)

HOMEPAGE = "http://people.seas.harvard.edu/~apw/stress/"
SUMMARY = "Generate load stress on UNIX-like operating systems"
DESCRIPTION = "a simple tool that imposes certain types of compute stress on UNIX-like operating systems."
LICENSE = "GPLv3"

inherit autotools

MIRRORS_prepend () {
   http://people.seas.harvard.edu/~apw/stress/ http://pkgs.fedoraproject.org/repo/pkgs/stress/stress-1.0.4.tar.gz/a607afa695a511765b40993a64c6e2f4/
}

SRC_URI=" \
    http://people.seas.harvard.edu/~apw/stress/stress-${PV}.tar.gz \
    file://texinfo.patch \
"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI[md5sum] = "a607afa695a511765b40993a64c6e2f4"
SRC_URI[sha256sum] = "369c997f65e8426ae8b318d4fdc8e6f07a311cfa77cc4b25dace465c582163c0"