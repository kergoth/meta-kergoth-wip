do_install_append_class-nativesdk_libc-musl () {
    rm -rf ${D}${libdir}/charset.alias
    rmdir ${D}${libdir}
}
