PKG_CONFIG_DEP = "virtual/pkg-config-native"
PKG_CONFIG_DEP_append_class-target = " virtual/${TARGET_PREFIX}pkg-config${@'-native' if oe.utils.inherits(d, 'allarch') else ''}"
PKG_CONFIG_DEP_append_class-cross = " virtual/${TARGET_PREFIX}pkg-config"
DEPENDS_prepend = "${PKG_CONFIG_DEP} "
