This WIP layer exists to facilitate minimizing the enabled PACKAGECONFIGS in
a build which pull in additional dependencies.

## Dependencies

This layer depends on:

- git://git.openembedded.org/bitbake, matching branch
- git://git.openembedded.org/openembedded-core, matching branch

## Usage

- Set up a build directory as usual
- Add the layer to your BBLAYERS
- Run `recipetool minimize-packageconfigs`, which writes out
  conf/disable-packageconfigs.conf
- Add `include conf/minimize-packageconfigs.conf`, which includes a config
  file from the layer which sources `conf/disable-packageconfigs.conf` and
  makes some adjustments to fix build issues

## Contributing

Please contribute through the github repository's issues and pull requests.
