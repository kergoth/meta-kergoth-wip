# Switches the majority of the default global variable exports to be exported
# as task exports only for the configure, compile, and install tasks.
#
# Kept global exports: PATH, PSEUDO_DISABLED, LC_ALL, CCACHE_DIR, CCACHE_DISABLE
# Exports removed entirely: BUILD_EXPORTS, TARGET_EXPORTS, and TARGET_PATH_EXPORTS

BASE_EXPORTS = "\
    AR AS CC CCLD CFLAGS CPP CPPFLAGS CXX CXXFLAGS FC LD LDFLAGS \
    MAKE NM OBJCOPY OBJDUMP RANLIB STRINGS STRIP \
    \
    ${PKG_CONFIG_EXPORTS} \
"
PACKAGE_EXPORTS = ""

# add_xorg_abi_depends needs to run pkg-config
PACKAGE_EXPORTS .= "${@'${PKG_CONFIG_EXPORTS}' if 'add_xorg_abi_depends' in '${PACKAGEFUNCS}'.split() else ''}"


DISABLED_EXPORTS = "\
    ${BUILD_EXPORTS} \
    ${TARGET_EXPORTS} \
    ${TARGET_PATH_EXPORTS} \
"

PKG_CONFIG_EXPORTS = "\
    PKG_CONFIG_DIR \
    PKG_CONFIG_DISABLE_UNINSTALLED \
    PKG_CONFIG_LIBDIR \
    PKG_CONFIG_PATH \
    PKG_CONFIG_SYSROOT_DIR \
    PKG_CONFIG_SYSTEM_INCLUDE_PATH \
    PKG_CONFIG_SYSTEM_LIBRARY_PATH \
"

BUILD_EXPORTS = "\
    BUILD_AR BUILD_AS BUILD_CC BUILD_CCLD BUILD_CFLAGS BUILD_CPP \
    BUILD_CPPFLAGS BUILD_CXX BUILD_CXXFLAGS BUILD_FC BUILD_LD BUILD_LDFLAGS \
    BUILD_NM BUILD_RANLIB BUILD_STRIP \
"
TARGET_EXPORTS = "TARGET_CFLAGS TARGET_CPPFLAGS TARGET_CXXFLAGS TARGET_LDFLAGS"
TARGET_PATH_EXPORTS = "\
    base_bindir base_libdir base_prefix base_sbindir bindir datadir \
    docdir exec_prefix includedir infodir libdir libexecdir localstatedir \
    mandir nonarch_base_libdir nonarch_libdir oldincludedir prefix \
    sbindir servicedir sharedstatedir sysconfdir systemd_system_unitdir \
    systemd_unitdir systemd_user_unitdir \
"

CONFIGURE_EXPORTS = "${BASE_EXPORTS}"
COMPILE_EXPORTS = "${BASE_EXPORTS}"
INSTALL_EXPORTS = "${BASE_EXPORTS}"

do_configure[exports] += "${CONFIGURE_EXPORTS}"
do_compile[exports] += "${COMPILE_EXPORTS}"
do_compile_ptest_base[exports] += "${COMPILE_EXPORTS}"
do_install[exports] += "${INSTALL_EXPORTS}"
do_install_ptest_base[exports] += "${INSTALL_EXPORTS}"
do_package[exports] += "${PACKAGE_EXPORTS}"

python () {
    for var in (d.getVar('BASE_EXPORTS', True).split() +
                d.getVar('DISABLED_EXPORTS', True).split()):
        d.delVarFlag(var, 'export')
}


POPULATE_SYSROOT_EXPORTS ?= ""

# do_siteconfig_gencache runs ./configure
POPULATE_SYSROOT_EXPORTS .= "${@' ${CONFIGURE_EXPORTS}' if bb.data.inherits_class('siteconfig', d) and os.path.isdir('${FILE_DIRNAME}/site_config') else ''}"

do_populate_sysroot[exports] += "${POPULATE_SYSROOT_EXPORTS}"
