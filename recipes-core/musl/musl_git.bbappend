DEPENDS += "linux-libc-headers"
DEPENDS_remove = "virtual/${TARGET_PREFIX}binutils"

BBCLASSEXTEND += "nativesdk"

# nativesdk blows away LDFLAGS with BUILDSDK_LDFLAGS after the recipe's
# changes, so they're lost.
BUILDSDK_LDFLAGS += "-Wl,-soname,libc.so"

do_install_append () {
	rm -f ${D}${bindir}/ldd
	lnr ${D}${libdir}/libc.so ${D}${bindir}/ldd
	rm -f ${D}${base_libdir}/ld-musl-i386.so.1
	lnr ${D}${libdir}/libc.so ${D}${base_libdir}/ld-musl-i386.so.1
}
