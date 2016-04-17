EXTRA_OEMAKE += "\
    'BUILD_CC=${BUILD_CC}' \
    \
    'bindir=${bindir}' \
    'sbindir=${sbindir}' \
    'mandir=${mandir}' \
    'includedir=${includedir}' \
    'libdir=${libdir}' \
    'confdir=${sysconfdir}' \
    'localedir=${datadir}/locale' \
    'docdir=${docdir}/${BPN}' \
"
