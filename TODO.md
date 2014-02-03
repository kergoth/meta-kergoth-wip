- Use format string variables to act as internal documentation of where the
  files we read and write are located
- Add further documentation to the bbclasses
- Add variable to opt-out of just provides or just depends of a particular
  auto package type. There are cases where dependency scanning doesn't work
  fully, yet the provides are still useful to satisfy deps of others.
- Consider dropping the .autodeps files, or just emitting them as a debugging
  aid, rather than running two packagefuncs and using them as inter-function
  communication.
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
