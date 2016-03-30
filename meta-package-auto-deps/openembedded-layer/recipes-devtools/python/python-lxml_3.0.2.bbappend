# Lxml supports both python 2 and 3, so has many imports in try/except blocks
# to handle module renames, and pythondeps isn't smart enough to handle that
# just yet
PYTHON_DEPS_SEARCH_PATHS = ""
