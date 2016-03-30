EXTRA_OEMAKE += "'docdir=${docdir}'"

python () {
    inst = d.getVar('do_install', False).replace('oe_runmake -e', 'oe_runmake')
    d.setVar('do_install', inst)
}
