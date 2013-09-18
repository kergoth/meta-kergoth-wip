# - Pygments modules are used by an external pygments plugin created by this,
#   but it isn't actually a dependency of python-mako, as far as I can tell.
# - The Babel plugin is seemingly optional, so leave it out for now.
# - markupsafe is optional

AUTO_PYTHON_DEPENDS_EXCLUDE += "\
    babel.messages.extract \
    markupsafe \
    pygments \
    pygments.formatters.html \
    pygments.lexer \
    pygments.lexers.agile \
    pygments.lexers.web \
    pygments.token \
"
