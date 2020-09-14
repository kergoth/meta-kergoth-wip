- Alter find-layer-with-path to prefer existing layers in BBLAYERS the way
  find-layer-by-name does currently
- Change the find-layer commands to use find-layers, to be more accurate
- Improve bitbake-layers-only-parse-bblayers to change the cooker semantics
  where construction implies config file parsing, rather than passing an
  argument to the constructor
