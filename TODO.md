- Use format string variables to act as internal documentation of where the files we read and write are located @inprogress

- Drop intermediate autodeps files as inter-function communication, if
  possible, in favor of emitting them just as a debugging aid, to simplify the core functionality.
- Add the ability to specify paths to exclude from the traversal

- Add further documentation to the bbclasses
- Add variable to opt-out of just provides or just depends of a particular
  auto package type. There are cases where dependency scanning doesn't work
  fully, yet the provides are still useful to satisfy deps of others.
- python:

    - Consider handling namespace packages
    - Add the ability to exclude particular files from the dependency scanning

- Add version-specific dependency handling.
  I think this should be doable by making each deps file in pkgdata a list
  of providers, and make each entry a versioned dep per bitbake, and alter
  the code to split that, and add the ability for a given type to opt-in to
  use of such version specific dependencies

- Consider adding the ability to postpone the mapping from the automatic
  dependency namespace to the binary package namespace. For example, it would
  be possible to add auto/python/os.path to RPROVIDES/RDEPENDS and let the
  package manager do the mapping.
- Add a sanity check which warns if an autodetected runtime dependency pulls
  in an rdepend which was emitted by a recipe we don't depend upon, to catch
  non-deterministic behavior

- Implement shlibs
- Implement kernel modules
- Implement perl, m4, ruby
- Add acquisition/release of the package lock if necessary

- Open yocto bug regarding a bitbake issue I found. 'd' isn't useable from
  inside a ${@} block expanded from a vardeps flag. It seemingly is not
  available in the python eval context at that point.
- libfm: ship .pc files based on the gtk version it was built with

- Failures to fix

   -  Missing deps:

        - python-dateutil
        - python-git
        - python-imaging
        - python-mako
        - python-matplotlib
        - python-nose
        - python-pip
        - python-pycurl
        - python-pyserial
        - python-scons
        - python-smartpm
        - python-sqlalchemy
        - python-tornado
        - python-twisted-core

    - Depscmd error:

        - python-pyrex
