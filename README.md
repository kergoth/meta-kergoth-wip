meta-package-auto-deps
======================

Temporary Yocto layer to hold work on a general mechanism for handling 'automatic' dependencies like shlibs, pkgconfig, kernel-modules, python, etc.

Usage
-----

- Add this layer path to your conf/bblayers.conf
- Inherit the bbclass from conf/local.conf: `INHERIT += "package-auto-deps"`
- Enable any automatic dep types you wish to test out: `AUTO_DEPEND_TYPES = "pkg-config python"`
- Examples of adding extra manual dependencies in the auto namespaces, and excluding
  automatic dependencies:

```
    AUTO_PYTHON_DEPENDS_EXTRA += "python-foo:os.path"
    AUTO_PYTHON_DEPENDS_EXCLUDE += "python-foo:urllib.parse"
    AUTO_PYTHON_PROVIDES_EXTRA += "python-core:os.path"
    AUTO_PYTHON_PROVIDES_EXCLUDE += "python-core:sys"
```
