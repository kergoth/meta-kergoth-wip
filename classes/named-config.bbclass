NAMED_CONFIG_SUFFIX ?= ""

python named_config_virtclass_handler () {
    cls = d.getVar("BBEXTENDCURR", True)
    variant = d.getVar("BBEXTENDVARIANT", True)
    if cls != "named-config" or not variant:
        return

    save_var_name = d.getVar("NAMED_CONFIG_SAVE_VARNAME", True) or ""
    for name in save_var_name.split():
        val = d.getVar(name, True)
        if val:
            d.setVar(name + "_NAMED_CONFIG_ORIGINAL", val)

    override = ":virtclass-named-config-" + variant
    overrides = d.getVar("OVERRIDES", False)
    pn = d.getVar("PN", False)
    overrides = overrides.replace("pn-${PN}", "pn-${PN}:pn-" + pn) + override
    d.setVar("OVERRIDES", overrides)

    # The variants provide the base, and aren't default
    d.appendVar("PROVIDES", " " + pn)

    # We want BPN to strip off the suffix
    d.appendVar("SPECIAL_PKGSUFFIX", " -" + variant)

    if not d.getVar("DEFAULT_PREFERENCE", True):
        d.setVar("DEFAULT_PREFERENCE", "-1")

    d.setVar("PN", d.getVar("PN", False) + "-" + variant)
    d.setVar("NAMED_CONFIG_SUFFIX", "-" + variant)

    # Expand the WHITELISTs with named-config suffix
    for whitelist in ["HOSTTOOLS_WHITELIST_GPL-3.0", "WHITELIST_GPL-3.0", "LGPLv2_WHITELIST_GPL-3.0"]:
        pkgs = d.getVar(whitelist, True)
        for pkg in pkgs.split():
            pkgs += " " + pkg + "-" + variant
        d.setVar(whitelist, pkgs)
}

addhandler named_config_virtclass_handler
named_config_virtclass_handler[eventmask] = "bb.event.RecipePreFinalise"
