EXTRA_OEMAKEINST = "\
    'DESTDIR=${D}' \
    'prefix=${prefix}' \
    'bindir=${DESTDIR}${bindir}' \
    'sbindir=${DESTDIR}${sbindir}' \
    'libdir=${DESTDIR}${libdir}' \
    'shrdir=${DESTDIR}/${datadir}' \
    'mandir=${DESTDIR}${mandir}' \
"

do_install () {
    oe_runmake ${EXTRA_OEMAKEINST} install
}
