FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

EXTRA_OEMAKE = "'bindir=${bindir}'"

do_compile () {
    oe_runmake linux
}

do_install () {
    oe_runmake 'DESTDIR=${D}' install
}
