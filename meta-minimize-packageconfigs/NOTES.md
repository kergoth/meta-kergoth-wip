# Packageconfig minimization task

## TODO

- [ ] Rework as an explicit operation that writes out a metadata file with
  `PACKAGECONFIG_remove_pn-` lines rather than doing it dynamically on the fly
  - 'bb' sub-command, perhaps?
- [ ] Review the disabled packageconfigs for sanity
  - [ ] rsync: acl and attr packageconfigs are unconditionally enabled rather
  than going based on the acl and xattr distro features, respectively
