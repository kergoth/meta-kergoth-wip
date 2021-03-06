# This is not needed and causes problems for nativesdk
DEPENDS_remove = "virtual/${TARGET_PREFIX}binutils"

BBCLASSEXTEND += "nativesdk"

# nativesdk blows away LDFLAGS with BUILDSDK_LDFLAGS after the recipe's
# changes, so they're lost.
BUILDSDK_LDFLAGS += "-Wl,-soname,libc.so"
