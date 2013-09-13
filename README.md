meta-package-auto-deps
======================

Temporary Yocto layer to hold work on a general mechanism for handling 'automatic' dependencies like shlibs, pkgconfig, kernel-modules, python, etc.

Usage
-----

- Add this layer path to your conf/bblayers.conf
- Inherit the bbclass from conf/local.conf: `INHERIT += "package-auto-deps"`
- Enable any automatic dep types you wish to test out: `AUTO_DEPEND_TYPES = "pkg-config python"`
