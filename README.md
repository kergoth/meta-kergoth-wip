This layer holds a prototype of a BBCLASSEXTEND-based approach to recipe
variants whose only difference is configuration (e.g. normal and minimal
busybox variants).


Dependencies
============

This layer depends on:

  URI: git://git.openembedded.org/bitbake
  branch: master

  URI: git://git.openembedded.org/openembedded-core
  layers: meta
  branch: master


Patches
=======

Please submit any patches via github's pull requests mechanism, and open
issues in github's issue tracker to report any problems.


Table of Contents
=================

   I. Adding the named-configs-prototype layer to your build
  II. Usage
 III. Limitations
  IV. TODO


I. Adding the named-configs-prototype layer to your build
=========================================================

In order to use this layer, you need to make the build system aware of
it:

    $ bitbake-layers add-layer /path/to/meta-named-configs-prototype

II. Usage
=========

To add a configuration variant for a specific recipe, in a bbappend:

    BBCLASSEXTEND += "named-configs:variant-name"

Then adjust the configuration (e.g. custom entry in filespath to override
a file, or PACKAGECONFIG, or whatever) as appropriate for the variant, using
either the virtclass or pn-based override.


III. Limitations
================

Since the variants are per-recipe, not global, there's currently no way to
automatically propogate any PREFERRED_VERSION_<recipe> to also apply to the
variants, the way it's done for multilibs.

IV. TODO
========

- [ ] Consider adding RPROVIDES/RCONFLICTS/RREPLACES of the original binary
  package names to all the binary packages, ideally also including dynamic, so
  selection could be handled on target as well as at build time.
