TOOLCHAIN_HOST_TASK := "${@oe.utils.str_filter_out('nativesdk-glibc.*', '${TOOLCHAIN_HOST_TASK}', d)}"

TCLIBC_NATIVESDK ?= "${TCLIBC}"
TOOLCHAIN_HOST_TASK += "nativesdk-${TCLIBC_NATIVESDK}"
