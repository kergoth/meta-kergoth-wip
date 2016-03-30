EXTRA_OECONF = "\
    'CC=${CC}' \
    'CFLAGS=${CFLAGS}' \
    'CPPFLAGS=${CPPFLAGS}' \
    'LDFLAGS=${LDFLAGS}' \
"

# ed uses a custom shell configure script, not autoconf, but it accepts the
# usual arguments, such as those for target paths, so inherit the class to get
# oe_runconf available
inherit autotools

do_configure () {
    oe_runconf
}
