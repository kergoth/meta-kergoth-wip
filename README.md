This layer holds work-in-progress metadata for kergoth

### Usage

Assuming a functional oe/poky build environment (with setup scripts sourced):

    $ git clone https://github.com/kergoth/meta-kergoth-wip
    $ for i in meta-kergoth-wip/*/conf/layer.conf; do bitbake-layers add-layer
    ${i%/conf/layer.conf}; done

### Content Review

- meta-pkgconf/recipes-devtools/pkgconf: This is an alternative to pkg-config
  which has no glib-2.0 dependency, which could potentially be useful to us.
  I'm vetting builds using it instead of pkg-config to check its sanity.
  Usage:

      PREFERRED_PROVIDER_pkgconfig = "pkgconf"
      PREFERRED_PROVIDER_pkgconfig-native = "pkgconf-native"
      PREFERRED_PROVIDER_nativesdk-pkgconfig = "nativesdk-pkgconf"
