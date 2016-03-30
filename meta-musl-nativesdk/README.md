Yocto layer for initial testing usage of musl for the nativesdk libc

## Dependencies

- [bitbake](https://github.com/openembedded/bitbake)
- [openembedded-core](https://github.com/openembedded/openembedded-core), meta layer

## Usage

- Add layer to BBLAYERS in your conf/bblayers.conf. I.e. `bitbake-layers add-layer /path/to/meta-musl-nativesdk-wip`.
- Add `require conf/musl-nativesdk.conf` to conf/local.conf.
