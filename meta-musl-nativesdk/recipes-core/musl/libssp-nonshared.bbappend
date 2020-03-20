# gcc in DEPENDS automatically gets the -crossdk suffix added, but not
# binutils, so we need to override it
DEPENDS_class-nativesdk = "virtual/${TARGET_PREFIX}binutils-crosssdk \
                           virtual/${TARGET_PREFIX}gcc-crosssdk"
BBCLASSEXTEND += "nativesdk"
