This repository holds work-in-progress metadata for kergoth

### Usage

Assuming a functional oe/poky build environment (with setup scripts sourced):

    $ git clone https://github.com/kergoth/meta-kergoth-wip
    $ for i in meta-kergoth-wip/*/conf/layer.conf; do bitbake-layers add-layer
    ${i%/conf/layer.conf}; done

### Layers

- meta-named-configs: Yocto layer for a prototype of a BBCLASSEXTEND-based
  approach to recipe variants whose only difference is configuration (e.g.
  normal and minimal busybox variants)
- meta-musl-nativesdk: Supports use of musl for nativesdk independent of the
  selected TCLIBC for target
- meta-package-auto-deps: Yocto layer to hold work on a general mechanism for
  handling 'automatic' dependencies like shlibs, pkgconfig, kernel-modules,
  python, etc
- meta-pkgconf: This has an alternative to pkg-config which has no glib-2.0
  dependency
