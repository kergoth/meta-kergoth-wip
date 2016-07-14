# Switches the majority of the default global variable exports to be exported
# as task exports only for the configure, compile, and install tasks.
#
# Kept global exports: PATH, PSEUDO_DISABLED, LC_ALL, CCACHE_DIR, CCACHE_DISABLE
# Exports removed entirely: BUILD_EXPORTS, TARGET_EXPORTS, and TARGET_PATH_EXPORTS

require conf/task-exports.conf

DISABLED_EXPORTS = '\
    ${BUILD_EXPORTS} \
    ${TARGET_EXPORTS} \
    ${TARGET_PATH_EXPORTS} \
'

BASE_TASK_EXPORTS_remove = '${DISABLED_EXPORTS}'

python unexport_task_exports () {
    for var in (d.getVar('BASE_TASK_EXPORTS', True).split() +
                d.getVar('DISABLED_EXPORTS', True).split()):
        d.delVarFlag(var, 'export')
}
unexport_task_exports[eventmask] = 'bb.event.ConfigParsed'
addhandler unexport_task_exports
