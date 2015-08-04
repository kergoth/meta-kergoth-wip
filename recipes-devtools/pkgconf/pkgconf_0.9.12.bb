SUMMARY = "pkgconf provides compiler and linker configuration for development frameworks."
DESCRIPTION = "${SUMMARY} pkgconf is an alternative implementation of pkg-config."
HOMEPAGE = "https://github.com/pkgconf/pkgconf"
BUGTRACKER = "https://github.com/pkgconf/pkgconf/issues"
SECTION = "console/utils"
PROVIDES += "pkgconfig"
RPROVIDES_${PN} += "pkgconfig"
RDEPENDS_${PN}-ptest += "bash"
DEFAULT_PREFERENCE = "-1"

# The pkgconf license seems to be functionally equivalent to BSD-2-Clause or
# ISC, but has different wording, so needs its own name.
LICENSE = "pkgconf"
LIC_FILES_CHKSUM = "file://COPYING;md5=4822b4dd464a74e654c7406a5f956ce4"

SRC_URI = "\
    http://rabbit.dereferenced.org/%7Enenolod/distfiles/pkgconf-${PV}.tar.bz2 \
    file://pkg-config-wrapper \
    file://pkg-config-native.in \
    file://run_test_fragment.sh \
"
SRC_URI[md5sum] = "a7b523fc9af9357d7199560d2a49ddbf"
SRC_URI[sha256sum] = "7ec8b516e655e247f4ba976837cee808134785819ab8f538f652fe919cc6c09f"
MIRRORS += "http://.*/.*/ https://github.com/pkgconf/pkgconf/releases/download/pkgconf-${PV}/\n "

inherit autotools update-alternatives ptest

EXTRA_OECONF += "--with-pkg-config-dir='${libdir}/pkgconfig:${datadir}/pkgconfig'"

PACKAGECONFIG ?= ""
# Enables POSIX-strict argument checking and disables some workarounds
PACKAGECONFIG[strict] = "--enable-strict,--disable-strict,,"

do_install_append () {
    install -m 0755 "${WORKDIR}/pkg-config-wrapper" "${D}${bindir}/pkg-config"
}

do_install_append_class-native () {
    # Install a pkg-config-native wrapper that will use the native sysroot instead
    # of the MACHINE sysroot, for using pkg-config when building native tools.
    sed -e "s|@PATH_NATIVE@|${PKG_CONFIG_PATH}|" \
        < ${WORKDIR}/pkg-config-native.in > ${B}/pkg-config-native
    install -m755 ${B}/pkg-config-native ${D}${bindir}/pkg-config-native
}

do_compile_ptest () {
    # We remove the run_test function from run.sh and provide our own, which
    # complies with the ptest conventions.
    install -m 0755 "${WORKDIR}/run_test_fragment.sh" tests/run-ptest
    sed -n -e '/^selfdir=/{ :start; /^echo$/q; p; n; b start; }' tests/run.sh >>tests/run-ptest
}

do_install_ptest_base () {
    install -d "${D}${PTEST_PATH}"
    cp -a "${B}/tests/." "${S}/tests"/*/ "${D}${PTEST_PATH}/"
}

ALTERNATIVE_${PN} = "pkg-config"

# When using the RPM generated automatic package dependencies, some packages
# will end up requiring 'pkgconfig(pkg-config)'.  Allow this behavior by
# specifying an appropriate provide.
RPROVIDES_${PN} += "pkgconfig(pkg-config)"

# Set an empty dev package to ensure the base PN package gets the pkg.m4
# macros, we don't deliver any other -dev files.
FILES_${PN}-dev = ""
FILES_${PN} += "${datadir}/aclocal/pkg.m4"

BBCLASSEXTEND += "native nativesdk"
