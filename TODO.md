- Use format string variables to act as internal documentation of where the
  files we read and write are located
- Add further documentation to the bbclasses
- python:

    - Determine if `PYTHONDEPS_FILE_CHECKSUM` is truly being included in the
      checksums for do_package, and if not, fix it. We need to ensure that we
      re-run our auto deps code when the scanner code changes.

- Add version-specific dependency handling
- Deal with the multiple provider case
- Implement shlibs
- Implement kernel modules
- Implement perl, m4, ruby
- Add acquisition/release of the package lock if necessary

- Open yocto bug regarding a bitbake issue I found. 'd' isn't useable from
  inside a ${@} block expanded from a vardeps flag. It seemingly is not
  available in the python eval context at that point.
