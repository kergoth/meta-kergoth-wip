# Disable all non-programmatically-set packageconfigs which introduce
# additional dependencies by default, forcing the user to consider each of
# them and add them back in explicitly via PACKAGECONFIG_BACKDEL_CONSIDERED.
# Packageconfigs set based on DISTRO_FEATURES will be left alone, as ${}
# blocks in PACKAGECONFIG are left alone. The mechanism is similar to
# DISTRO_FEATURES backfill, except that we're removing rather than adding on
# the backend.

PACKAGECONFIG_BACKDEL_ENABLED ?= "1"
PACKAGECONFIG_BACKDEL_ENABLED[type] = "boolean"

PACKAGECONFIG_BACKDEL ?= "${@' '.join(get_packageconfigs_with_deps(d))}"
PACKAGECONFIG_BACKDEL[type] = "list"

PACKAGECONFIG_BACKDEL_CONSIDERED ?= ""
PACKAGECONFIG_BACKDEL_CONSIDERED[type] = "list"

PACKAGECONFIG_BACKDEL_VERBOSE ?= "0"
PACKAGECONFIG_BACKDEL_VERBOSE[type] = "boolean"
PACKAGECONFIG_BACKDEL_VERBOSE[doc] = "Increase backdel verbosity: show warnings instead of debug messages, for debugging"

PACKAGECONFIG_BACKDEL_LOGFILE ?= "${LOG_DIR}/packageconfig-backdel/${DATETIME}.txt"
PACKAGECONFIG_BACKDEL_LOGFILE[doc] = "Log file holding the configs removed for each recipe."
PACKAGECONFIG_BACKDEL_LOGFILE_KEPT ?= "${LOG_DIR}/packageconfig-backdel/${DATETIME}-kept.txt"
PACKAGECONFIG_BACKDEL_LOGFILE_KEPT[doc] = "Log file holding the configs kept for each recipe due to inline python."

# RPM 5's beecrypt dependency is mandatory, and librpm/librpmdb will fail to
# link without a db, and our packaging relies on debugedit, which is only
# built if libelf is enabled.
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-rpm = " beecrypt db libelf"
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-rpm-native = " beecrypt db libelf python"
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-rpm-nativesdk = " beecrypt db libelf"

# Smart is pretty useless to us without its rpm support
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-python-smartpm = " rpm"
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-python-smartpm-native = " rpm"
# This is suffixed rather than prefixed, as we're currently running before the
# virtclass event handler in nativesdk.bbclass.
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-python-smartpm-nativesdk = " rpm"

# egl requires dri, so also consider its removal if we're considering removing
# dri for its deps
PACKAGECONFIG_BACKDEL_append_pn-mesa = " egl"

# Qemu needs fdt for some targets
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-qemu-native = " fdt"
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-qemu = " fdt"

# WPA needs either gnutls or openssl -- it cannot be built with neither
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-wpa-supplicant = " gnutls openssl"

# I don't mind these deps
PACKAGECONFIG_BACKDEL_CONSIDERED += "\
    zlib \
    bzip bzip2 \
    ssl openssl gnutls \
"

# I want egl/gles if appropriate
PACKAGECONFIG_BACKDEL_CONSIDERED_append_pn-mesa = " egl dri"


python packageconfig_backdel () {
    """Disable all optional dependencies. Prototype."""
    if not oe.data.typed_value('PACKAGECONFIG_BACKDEL_ENABLED', d):
        return

    backdel = set(oe.data.typed_value('PACKAGECONFIG_BACKDEL', d))
    considered = set(oe.data.typed_value('PACKAGECONFIG_BACKDEL_CONSIDERED', d))
    backdel -= considered
    if backdel:
        packageconfig = d.getVar('PACKAGECONFIG', False) or ''
        if not packageconfig:
            return

        new, removed, kept = [], set(), set()
        if '${' not in packageconfig:
            for i in packageconfig.split():
                if i in backdel:
                    removed.add(i)
                else:
                    new.append(i)
        else:
            # Leave variable references and inline python alone, as we want
            # DISTRO_FEATURES-based-configs left intact.
            parsed = parse(packageconfig)
            for element in parsed:
                if isinstance(element, basestring):
                    for e in element.strip().split():
                        if e in backdel:
                            removed.add(e)
                        else:
                            new.append(e)
                else:
                    element = parsed_to_string(element)
                    for e in element.strip().split():
                        if e in backdel:
                            kept.add(e)
                    new.append(element)

        if kept:
            logfile = d.getVar('PACKAGECONFIG_BACKDEL_LOGFILE_KEPT', True)
            if logfile:
                bb.utils.mkdirhier(os.path.dirname(logfile))
                with open(logfile, 'a') as f:
                    f.write('%s:%s\n' % (d.getVar('PN', True), ','.join(sorted(kept))))

        if removed:
            logfile = d.getVar('PACKAGECONFIG_BACKDEL_LOGFILE', True)
            if logfile:
                bb.utils.mkdirhier(os.path.dirname(logfile))
                with bb.utils.fileslocked([logfile + '.lock']):
                    with open(logfile, 'a') as f:
                        f.write('PACKAGECONFIG_remove_pn-%s = "%s"\n' % (d.getVar('PN', True), ' '.join(sorted(removed))))

            if oe.data.typed_value('PACKAGECONFIG_BACKDEL_VERBOSE', d):
                bb.warn(d.expand('${PF}: packageconfig-backdel disabled packageconfigs: %s' % ' '.join(removed)))
            else:
                bb.debug(1, d.expand('${PF}: packageconfig-backdel disabled packageconfigs: %s' % ' '.join(removed)))
            d.setVar('PACKAGECONFIG', ' '.join(new))
}
# This is running as RecipePreFinalise currently to ensure it runs before the
# packageconfig processing in base.bbclass.
packageconfig_backdel[eventmask] = "bb.event.RecipePreFinalise"
addhandler packageconfig_backdel


def parse(string):
    def _parse(iterator, context):
        for i in iter_except(iterator.next, StopIteration):
            if i.startswith('${'):
                context.append(_parse(iterator, [i]))
            elif i == '}':
                return context + [i]
            else:
                context.append(i)
        return context

    import re
    variable_ref = re.compile(r"(\$\{|\})")
    tokens = filter(None, variable_ref.split(string))
    iterator = iter(tokens)
    return _parse(iterator, [])


def iter_except(func, exception, start=None):
    'Yield a function repeatedly until it raises an exception'
    try:
        if start is not None:
            yield start()
        while 1:
            yield func()
    except exception:
        pass


def parsed_to_string(parsed):
    l = []
    for i in parsed:
        if isinstance(i, basestring):
            l.append(i)
        else:
            l.append(parsed_to_string(i))
    return ''.join(l)


def get_packageconfigs_with_deps(d, configs=None):
    if configs is None:
        configs = (d.getVar('PACKAGECONFIG', True) or '').split()
    return filter(lambda p: packageconfig_has_deps(d.getVarFlag('PACKAGECONFIG', p, False) or ''), configs)


def packageconfig_has_deps(config):
    parts = config.split(',')
    if len(parts) > 4:
        return False

    cfg_if_enable, cfg_if_disable, depends, rdepends = iter_extend(parts, 4)
    return depends or rdepends


def iter_extend(iterable, length, obj=None):
    """Ensure that iterable is the specified length by extending with obj"""
    import itertools
    return itertools.islice(itertools.chain(iterable, itertools.repeat(obj)), length)
