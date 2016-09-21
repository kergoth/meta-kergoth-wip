import argparse
import collections
import logging

import os
import sys
import tempfile

import bb.cookerdata
import bb.utils

from bblayers.common import LayerPlugin

logger = logging.getLogger('bitbake-layers')


def plugin_init(plugins):
    return MELPlugin()


class LayerNotFound(Exception):
    def __init__(self, name, parseerrors=None):
        self.name = name
        self.parseerrors = parseerrors

    def __repr__(self):
        return '{0.__class__.__name__}({0.name!r}, {0.parseerrors!r})'.format(self)

    def __str__(self):
        msg = 'Layer not found with name "{0.name}"'.format(self)
        if self.parseerrors:
            msg += '. Parse errors occurred:\n{0}'.format(''.join('  {0}: {1}\n'.format(lconf, err) for lconf, err in self.parseerrors))
        return msg


class DuplicateLayers(Exception):
    def __init__(self, name, paths):
        self.name = name
        self.paths = paths

    def __repr__(self):
        return '{0.__class__.__name__}({0.name!r}, {0.paths!r})'.format(self)

    def __str__(self):
        path_lines = ''.join('  %s\n' % p for p in self.paths)
        return 'Duplicate layers with name "{0.name}":\n{1}'.format(self, path_lines)


class MELPlugin(LayerPlugin):
    def do_sort_layers(self, args):
        """Sort configured layers by layer priority."""
        layer_priorities = {}

        def remove_trailing_sep(pth):
            if pth and pth[-1] == os.sep:
                pth = pth[:-1]
            return pth

        approved = bb.utils.approved_variables()
        def canonicalise_path(pth):
            pth = remove_trailing_sep(pth)
            if 'HOME' in approved and '~' in pth:
                pth = os.path.expanduser(pth)
            return pth

        for layer, _, _, pri in self.tinfoil.cooker.bbfile_config_priorities:
            layerdir = canonicalise_path(self.bbfile_collections.get(layer, None))
            layer_priorities[layerdir] = pri

        bblayers = list(sorted(layer_priorities, key=lambda l: layer_priorities[l], reverse=True))
        orig_bblayers = self.tinfoil.config_data.getVar('BBLAYERS', True).split()
        for layer in orig_bblayers:
            if layer not in bblayers:
                bblayers.append(layer)

        def set_first_bblayers_only(varname, origvalue, op, newlines):
            if bblayers:
                newvalue = list(bblayers)
                del bblayers[:]
                return newvalue, '=', 2, False
            else:
                return None, None, 2, False

        bblayers_conf = bb.cookerdata.findConfigFile("bblayers.conf", self.tinfoil.config_data)
        if not bblayers_conf:
            sys.stderr.write("Unable to find bblayers.conf\n")
            return 1

        bb.utils.edit_metadata_file(bblayers_conf, ['BBLAYERS'], set_first_bblayers_only)

    def do_reset_layers(self, args):
        """Reset configured layers to the template or baseline value.

        If conf/templateconf.cfg points to a valid path, we use the BBLAYERS
        from the bblayers.conf.sample there. If not, all layers but oe-core
        are removed.
        """

        for layer, _, _, pri in self.tinfoil.cooker.bbfile_config_priorities:
            layerdir = self.bbfile_collections.get(layer, None)
            if layer == 'core':
                core = layerdir
                break
        else:
            logger.critical('oe-core/meta not found in the configured layers, aborting')
            return 1

        wanted_layers = [core]
        templateconf = bb.cookerdata.findConfigFile('templateconf.cfg',
                                                     self.tinfoil.config_data)
        if templateconf:
            data = bb.data.init()

            with open(templateconf, 'r+b') as f:
                templatepath = f.read().rstrip()

            bblayers_tmpl = os.path.join(templatepath, b'bblayers.conf.sample')
            if os.path.exists(bblayers_tmpl):
                logger.info('Using %s', bblayers_tmpl.decode())
                cfgfile = tempfile.NamedTemporaryFile(suffix='.conf', delete=False)
                try:
                    with cfgfile, open(bblayers_tmpl, 'r+b') as tmplfile:
                        cfgfile.write(tmplfile.read())

                    data = bb.cookerdata.parse_config_file(cfgfile.name, data)
                finally:
                    os.unlink(cfgfile.name)

                layers_tmpl = data.getVar('BBLAYERS', True).replace('\\n', '\n').strip()
                if layers_tmpl:
                    oeroot = os.path.dirname(os.path.dirname(core))
                    wanted_layers = layers_tmpl.replace('##OEROOT##', oeroot).replace('##COREBASE##', oeroot).split()

        to_add = []
        to_remove = self.tinfoil.config_data.getVar('BBLAYERS', True).split()
        for l in wanted_layers:
            if l in to_remove:
                to_remove.remove(core)
            else:
                to_add.append(l)

        bblayers_conf = bb.cookerdata.findConfigFile('bblayers.conf',
                                                     self.tinfoil.config_data)
        if not bblayers_conf:
            sys.stderr.write('Unable to find bblayers.conf\n')
            return 1

        bb.utils.edit_bblayers_conf(bblayers_conf, to_add, to_remove)

    def find_layers(self, patternstring):
        """Return the layers for a given patternstring."""
        import glob

        patternstring = self.tinfoil.config_data.expand(patternstring)
        for pattern in patternstring.split():
            for lconf in glob.glob(os.path.join(pattern, 'conf', 'layer.conf')):
                lconf = os.path.realpath(lconf)
                layerdir = os.path.dirname(os.path.dirname(lconf))
                yield lconf, layerdir

    def get_layers_by_name(self, patternstring):
        """Return a mapping of layer name to layer path.

        Prefer those already in BBLAYERS to those which are found on disk.
        The layer name is the name defined in BBFILE_COLLECTIONS.
        """
        by_name, configured = collections.defaultdict(set), []
        varhistory = self.tinfoil.config_data.varhistory
        layer_filemap = varhistory.get_variable_items_files('BBFILE_COLLECTIONS', self.tinfoil.config_data)
        for item, filename in layer_filemap.items():
            by_name[item].add(os.path.dirname(os.path.dirname(filename)))
            configured.append(item)

        data, errors = bb.data.init(), []
        bb.parse.init_parser(data)
        for lconf, layerdir in sorted(self.find_layers(patternstring)):
            ldata = data.createCopy()
            ldata.setVar('LAYERDIR', layerdir)
            try:
                ldata = bb.parse.handle(lconf, ldata, include=True)
            except BaseException as exc:
                errors.append([lconf, exc])
                continue

            names = (ldata.getVar('BBFILE_COLLECTIONS', True) or '').split()
            if not names:
                names = [os.path.basename(layerdir)]

            if any(name in configured for name in names):
                # Prioritize layers already in BBLAYERS
                continue

            for name in names:
                by_name[name].add(layerdir)

        return by_name, errors

    def find_layers_by_name(self, names, patternstring):
        by_name, errors = self.get_layers_by_name(patternstring)
        for name in names:
            layerdirs = by_name.get(name)
            if not layerdirs:
                raise LayerNotFound(name, errors)
            elif len(layerdirs) > 1:
                raise DuplicateLayers(name, layerdirs)
            else:
                layerdir = next(iter(layerdirs))
                yield name, layerdir

    def do_find_layer_by_name(self, args):
        """find the layer(s) for a given layer name, using a specific list of layers/wildcards to search"""
        try:
            for name, layerdir in self.find_layers_by_name(args.names, args.search_globs):
                logger.plain(layerdir)
        except LayerNotFound as exc:
            logger.error(str(exc))
            if exc.parseerrors:
                return 2
            else:
                return 1
        except DuplicateLayers as exc:
            logger.error(str(exc))
            return 3

    def do_find_layer_with_path(self, args):
        """find the layers which contain a specified path, using a specific list of layers/wildcards to search"""
        layers = collections.defaultdict(list)
        for lconf, layerdir in self.find_layers(args.search_globs):
            for path in args.paths:
                if os.path.exists(os.path.join(layerdir, path)):
                    layers[path].append(layerdir)

        for path in args.paths:
            if path in layers:
                for layer in layers[path]:
                    logger.plain(layer)
            else:
                logger.error('Failed to find layers including "%s"', path)
                return 1

    def register_commands(self, sp):
        self.add_command(sp, 'sort-layers', self.do_sort_layers, parserecipes=False)
        self.add_command(sp, 'reset-layers', self.do_reset_layers, parserecipes=False)

        find_common = argparse.ArgumentParser(add_help=False)
        find_common.add_argument('-g', '--search-globs', default='* */* ${COREBASE}/../* ${COREBASE}/../*/*', help='Space-separated list of layers to search (default: %(default)s)')

        find_layer_by_name = self.add_command(sp, 'find-layer-by-name', self.do_find_layer_by_name, parents=[find_common], parserecipes=False)
        find_layer_by_name.add_argument('names', nargs='+', metavar='NAME', help='Layer names (as specified in layer.conf, in BBFILE_COLLECTIONS)')

        find_layer_by_path = self.add_command(sp, 'find-layer-with-path', self.do_find_layer_with_path, parents=[find_common], parserecipes=False)
        find_layer_by_path.add_argument('paths', nargs='+', metavar='PATH', help='Path to find')
