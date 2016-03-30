SUMMARY = "Cross-compilation wrapper for pkg-config. Ensures that pkgconfig-native obeys target paths and looks at the target sysroot."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
INHIBIT_DEFAULT_DEPS = "1"
DEPENDS = "pkgconfig-native"

# Expand before inheriting cross, as we need these with target paths
PKG_CONFIG_DIR := "${PKG_CONFIG_DIR}"
PKG_CONFIG_DISABLE_UNINSTALLED := "${PKG_CONFIG_DISABLE_UNINSTALLED}"
PKG_CONFIG_LIBDIR := "${PKG_CONFIG_LIBDIR}"
PKG_CONFIG_PATH := "${PKG_CONFIG_PATH}"
PKG_CONFIG_SYSROOT_DIR := "${PKG_CONFIG_SYSROOT_DIR}"
PKG_CONFIG_SYSTEM_INCLUDE_PATH := "${PKG_CONFIG_SYSTEM_INCLUDE_PATH}"
PKG_CONFIG_SYSTEM_LIBRARY_PATH := "${PKG_CONFIG_SYSTEM_LIBRARY_PATH}"

inherit cross

PN .= "-${TARGET_ARCH}"
PROVIDES += "virtual/${TARGET_PREFIX}pkg-config"

bindir_to_native = "${@os.path.relpath('${STAGING_DIR_NATIVE}${bindir_native}', '${bindir}')}"

do_compile () {
    cat >pkg-config-cross <<END
#!/bin/sh
export PKG_CONFIG_DIR="${PKG_CONFIG_DIR}"
export PKG_CONFIG_DISABLE_UNINSTALLED="${PKG_CONFIG_DISABLE_UNINSTALLED}"
export PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
export PKG_CONFIG_SYSROOT_DIR="${PKG_CONFIG_SYSROOT_DIR}"
export PKG_CONFIG_SYSTEM_INCLUDE_PATH="${PKG_CONFIG_SYSTEM_INCLUDE_PATH}"
export PKG_CONFIG_SYSTEM_LIBRARY_PATH="${PKG_CONFIG_SYSTEM_LIBRARY_PATH}"
exec "\$(dirname "\$0")/${bindir_to_native}/pkg-config.real" "\$@"
END
    chmod +x pkg-config-cross
}

do_install () {
    install -d "${D}${bindir}"
    install -m 0755 pkg-config-cross "${D}${bindir}/pkg-config"
}
