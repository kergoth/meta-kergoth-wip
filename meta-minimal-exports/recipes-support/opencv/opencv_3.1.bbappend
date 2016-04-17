python () {
    inst = d.getVar('do_install', False)
    d.setVar('do_install', inst.replace('$libdir', '${libdir}'))
}
