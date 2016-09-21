This layer contains bits for the forthcoming upstream submissions of features
from meta-mentor's setup scripts for oe-core.

## Dependencies

- https://github.com/kergoth/bitbake, bitbake-layers-only-parse-bblayers branch
- https://github.com/openembedded/openembedded-core, matching branch

## Contribution

Contributions are welcome, via the github project issues and pull requests.

## Example Usage

```
$ /path/to/meta-setup-scripts-mentor/scripts/setup-layers -m qemux86-64 -d mel -s yocto mel-support mentor-staging openembedded-layer
NOTE: Using /scratch/projects/setup-scripts/meta-mentor/conf/bblayers.conf.sample
Specified layer /scratch/projects/setup-scripts/oe-core/meta is already in BBLAYERS
$ cat conf/bblayers.conf
MELDIR = "/scratch/projects/setup-scripts"

LCONF_VERSION = "7"

TOPDIR := "${@os.path.dirname(os.path.dirname(FILE))}"
BBPATH = "${TOPDIR}:${HOME}/.oe"
BBFILES ?= ""

BBLAYERS = " \
  /scratch/projects/setup-scripts/meta-mentor/meta-mel \
  /scratch/projects/setup-scripts/meta-mentor/meta-mentor-staging \
  /scratch/projects/setup-scripts/meta-openembedded/meta-oe \
  /scratch/projects/setup-scripts/meta-yocto/meta-poky \
  /scratch/projects/setup-scripts/oe-core/meta \
  /scratch/projects/setup-scripts/meta-mentor/meta-mel-support \
  "
BBFILE_PRIORITY_openembedded-layer_mel = "1"
```
