python () {
    inst = d.getVar('do_install', False).replace('$exec_prefix', '${exec_prefix}')
    d.setVar('do_install', inst)
}
