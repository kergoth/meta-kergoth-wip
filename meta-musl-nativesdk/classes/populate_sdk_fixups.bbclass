SHAR_EXTRACT_SCRIPT = "${@bb.utils.which('${BBPATH}', 'files/toolchain-shar-extract.sh')}"
SHAR_RELOCATE_SCRIPT = "${@bb.utils.which('${BBPATH}', 'files/toolchain-shar-relocate.sh')}"

do_populate_sdk[file-checksums] = "${SHAR_EXTRACT_SCRIPT}:True ${SHAR_RELOCATE_SCRIPT}:True"

python () {
    cs = d.getVar('create_shar', False)
    cs = cs.replace('${COREBASE}/meta/files/toolchain-shar-extract.sh', '${SHAR_EXTRACT_SCRIPT}')
    cs = cs.replace('${COREBASE}/meta/files/toolchain-shar-relocate.sh', '${SHAR_RELOCATE_SCRIPT}')
    d.setVar('create_shar', ''.join(cs))
}
