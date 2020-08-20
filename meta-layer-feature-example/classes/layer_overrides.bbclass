def unique_everseen(iterable):
    "List unique elements, preserving order. Remember all elements ever seen."
    # unique_everseen('AAAABBBCCDAABBB') --> A B C D
    # unique_everseen('ABBCcAD', str.lower) --> A B C D
    import itertools
    seen = set()
    seen_add = seen.add
    for element in itertools.filterfalse(seen.__contains__, iterable):
        seen_add(element)
        yield element

python add_layer_overrides () {
    layer_overrides = filter(None, d.getVar('LAYEROVERRIDES').split(':'))
    if layer_overrides:
        d.prependVar('OVERRIDES', ':'.join(unique_everseen(layer_overrides)) + ':')
}
add_layer_overrides[eventmask] = "bb.event.ConfigParsed"
addhandler add_layer_overrides
