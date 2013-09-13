PACKAGEFUNCS_remove = "package_do_pkgconfig"

AUTO_DEPEND_PKG-CONFIG_HOOK = "determine_pkgconfig_provides determine_pkgconfig_depends"

def determine_pkgconfig_provides(d, pkg, files):
    provides = []
    for file in files:
        base, ext = os.path.splitext(os.path.basename(file))
        if ext == '.pc':
            provides.append(base)

    return provides

def determine_pkgconfig_depends(d, pkg, files):
    import re

    depends = []

    field_re = re.compile('(?P<var>[^:]+): (?P<val>.*)')
    var_re = re.compile('(?P<var>[^=]+)=(?P<val>.*)')
    for file in files:
        if not file.endswith('.pc'):
            continue

        if not os.access(file, os.R_OK):
            continue

        with open(file, 'r') as f:
            lines = f.readlines()

        pd = bb.data.init()
        for l in lines:
            l = l.rstrip()

            var_match = var_re.match(l)
            field_match = field_re.match(l)

            if field_match:
                if field_match.group('var') == 'Requires':
                    exp = bb.data.expand(field_match.group('val'), pd)
                    for entry in exp.split(','):
                        try:
                            dep, ver = entry.split(' ', 1)
                        except ValueError:
                            dep = entry
                        depends.append(dep)
            elif var_match:
                pd.setVar(var_match.group('var'), var_match.group('val'))

    return depends
