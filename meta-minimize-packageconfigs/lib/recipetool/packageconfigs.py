# Copyright (C) 2015,2016 Mentor Graphics Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import collections
import itertools
import logging
import sys


logger = logging.getLogger('recipetool')
tinfoil = None


def register_command(subparsers):
    parser = subparsers.add_parser('minimize-packageconfigs', help='Write lines to the specified FILE to disable all packageconfigs which add additional dependencies, to help pare down the build.')
    parser.add_argument('filename', help='Filename to write, or - for stdout (default="%(default)s"). Configs to be removed are written to PACKAGECONFIGS_DISABLED_pn-<pn> variables, so the user can use _remove to exclude entries from the removal.', nargs='?', metavar='FILE', default='conf/disable-packageconfigs.conf')
    parser.set_defaults(func=disable_packageconfigs_deps, parserecipes=True)


def disable_packageconfigs_deps(args):
    if args.filename == '-':
        outfile = sys.stdout
    else:
        outfile = open(args.filename, 'w')

    seen_configs = collections.defaultdict(set)
    try:
        outfile.write('PACKAGECONFIG_remove = "${PACKAGECONFIGS_DISABLED}"\n')
        outfile.write('PACKAGECONFIGS_DISABLED ??= ""\n')
        for pn, configs in get_packageconfigs():
            dep_configs = [c for c, v in configs if packageconfig_has_deps(v)]
            seen = seen_configs[pn]
            disable_configs = set(dep_configs) - seen
            if disable_configs:
                # Collect all the configs for the case where they differ
                # between different versions of the same recipe
                if seen:
                    op = '+='
                else:
                    op = '='
                seen_configs[pn] |= disable_configs
                outfile.write('PACKAGECONFIGS_DISABLED_pn-%s %s "%s"\n' % (pn, op, ' '.join(sorted(disable_configs))))
    finally:
        if args.filename != '-':
            outfile.close()
            sys.stderr.write('Wrote to %s\n' % args.filename)


def get_packageconfigs():
    pkg_pn = tinfoil.cooker.recipecache.pkg_pn
    pkg_fn = tinfoil.cooker.recipecache.pkg_fn
    files = itertools.chain.from_iterable(pkg_pn.itervalues())
    for fn in unique_everseen(files):
        data = bb.cache.Cache.loadDataFull(fn, tinfoil.cooker.collection.get_file_appends(fn), tinfoil.config_data)

        configs = data.getVarFlags('PACKAGECONFIG')
        if 'doc' in configs:
            configs.pop('doc')

        if configs:
            pn = pkg_fn[fn]
            data.setVar('PACKAGECONFIGS_DISABLED', '')
            data.setVar('PACKAGECONFIGS_DISABLED_pn-%s' % pn, '')
            current_configs = data.getVar('PACKAGECONFIG', False)

            to_disable = set(configs) & set(packageconfigs_to_disable(current_configs))
            yield pn, [(c, data.getVarFlag('PACKAGECONFIG', c, False)) for c in sorted(to_disable)]


def unique_everseen(iterable, key=None):
    "List unique elements, preserving order. Remember all elements ever seen."
    # unique_everseen('AAAABBBCCDAABBB') --> A B C D
    # unique_everseen('ABBCcAD', str.lower) --> A B C D
    seen = set()
    seen_add = seen.add
    if key is None:
        for element in itertools.ifilterfalse(seen.__contains__, iterable):
            seen_add(element)
            yield element
    else:
        for element in iterable:
            k = key(element)
            if k not in seen:
                seen_add(k)
                yield element


def packageconfigs_to_disable(packageconfig):
    if '${' not in packageconfig:
        for e in packageconfig.strip().split():
            yield e
    else:
        # Leave variable references and inline python alone, as we want
        # DISTRO_FEATURES-based-configs left intact.
        parsed = parse(packageconfig)
        for element in parsed:
            if isinstance(element, basestring):
                for e in element.strip().split():
                    yield e


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


def packageconfig_has_deps(config):
    parts = config.split(',')
    if len(parts) > 4:
        return False

    cfg_if_enable, cfg_if_disable, depends, rdepends = iter_extend(parts, 4)
    return depends or rdepends


def iter_extend(iterable, length, obj=None):
    """Ensure that iterable is the specified length by extending with obj"""
    return itertools.islice(itertools.chain(iterable, itertools.repeat(obj)), length)


def plugin_init(pluginlist):
    # Don't need to do anything here right now, but plugins must have this function defined
    pass


def tinfoil_init(instance):
    global tinfoil
    tinfoil = instance
