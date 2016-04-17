FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0002-Obey-LDFLAGS.patch"

EXTRA_OEMAKE = "'bindir=${bindir}'"

do_compile () {
    oe_runmake linux
}

do_install () {
    oe_runmake 'DESTDIR=${D}' install
}
