PROVIDES += "virtual/${TARGET_PREFIX}pkg-config"
# This provide is handled by pkgconfig-cross
PROVIDES_remove_class-target = "virtual/${TARGET_PREFIX}pkg-config"

pkgconfig_wrap () {
    create_wrapper "${D}${bindir}/pkg-config" \
        PKG_CONFIG_PATH=${PKG_CONFIG_PATH} \
        PKG_CONFIG_DIR=${PKG_CONFIG_DIR} \
        PKG_CONFIG_DISABLE_UNINSTALLED=${PKG_CONFIG_DISABLE_UNINSTALLED} \
        PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR} \
        PKG_CONFIG_SYSROOT_DIR=${PKG_CONFIG_SYSROOT_DIR} \
        PKG_CONFIG_SYSTEM_INCLUDE_PATH=${PKG_CONFIG_SYSTEM_INCLUDE_PATH} \
        PKG_CONFIG_SYSTEM_LIBRARY_PATH=${PKG_CONFIG_SYSTEM_LIBRARY_PATH}
}

do_install_append_class-native () {
    pkgconfig_wrap
    ln -sf pkg-config "${D}${bindir}/pkg-config-native"
}

do_install_append_class-nativesdk () {
    pkgconfig_wrap
}
