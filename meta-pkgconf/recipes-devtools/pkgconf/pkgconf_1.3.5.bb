SUMMARY = "pkgconf provides compiler and linker configuration for development frameworks."
DESCRIPTION = "pkgconf is a program which helps to configure compiler and linker \
flags for development frameworks. It is similar to pkg-config from \
freedesktop.org, providing additional functionality while also maintaining \
compatibility."
HOMEPAGE = "http://pkgconf.org"
BUGTRACKER = "https://github.com/pkgconf/pkgconf/issues"
SECTION = "devel"
PROVIDES += "pkgconfig"
RPROVIDES_${PN} += "pkgconfig"
RDEPENDS_${PN}-ptest += "bash"
DEFAULT_PREFERENCE = "-1"

# The pkgconf license seems to be functionally equivalent to BSD-2-Clause or
# ISC, but has different wording, so needs its own name.
LICENSE = "pkgconf"
LIC_FILES_CHKSUM = "file://COPYING;md5=548a9d1db10cc0a84810c313a0e9266f"

SRC_URI = "\
    https://distfiles.dereferenced.org/pkgconf/pkgconf-${PV}.tar.gz \
    file://pkg-config-wrapper \
    file://pkg-config-native.in \
    file://run_test_fragment.sh \
"
SRC_URI[md5sum] = "ce2533e12f03c4f8eb04179f86be666f"
SRC_URI[sha256sum] = "0909f0ace2f9d73c02f568bda05a95b717a652d692642f16e28701e3d86096db"
MIRRORS += "http://.*/.*/ https://github.com/pkgconf/pkgconf/releases/download/pkgconf-${PV}/\n "

inherit autotools update-alternatives ptest

EXTRA_OECONF += "--with-pkg-config-dir='${libdir}/pkgconfig:${datadir}/pkgconfig'"

do_install_append () {
    # Install a wrapper which deals, as much as possible with pkgconf vs
    # pkg-config compatibility issues.
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
