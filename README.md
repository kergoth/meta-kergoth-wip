This layer holds work-in-progress metadata for kergoth

### Setup

Assuming a functional oe/poky build environment:

$ git clone https://github.com/kergoth/meta-kergoth/wip
$ bitbake-layers add-layer meta-kergoth-wip

### Current content review

- recipes-devtools/pkgconf: This is an alternative to pkg-config which has no
  glib-2.0 dependency, which could potentially be useful to us. I'm vetting
  builds using it instead of pkg-config to check its sanity.
