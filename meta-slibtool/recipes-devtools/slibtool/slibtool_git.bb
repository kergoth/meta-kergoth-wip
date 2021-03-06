LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.SLIBTOOL;md5=b98dcfb4f40f76196a7cd2ed1fa48979"

SRC_URI = "git://github.com/midipix-project/slibtool;branch=main"
S = "${WORKDIR}/git"
B = "${S}"
PV = "0.5.28+git${SRCPV}"
SRCREV = "${AUTOREV}"

do_configure () {
    ./configure ${CONFIGUREOPTS}
}

do_compile () {
    oe_runmake
}

do_install () {
    oe_runmake 'DESTDIR=${D}' install
}

BBCLASSEXTEND = "native"

CONFIGUREOPTS = "\
	--prefix=${prefix} \
	--exec-prefix=${exec_prefix} \
	--bindir=${bindir} \
	--libdir=${libdir} \
	--includedir=${includedir} \
	--mandir=${mandir} \
	--libexecdir=${libexecdir} \
"
CONFIGUREOPTS_append_class-target = "\
	--build=${BUILD_SYS} \
	--host=${HOST_SYS} \
	--target=${TARGET_SYS} \
"

# 'ARCH=${HOST_ARCH}'
# 'NATIVE_ARCH=${BUILD_ARCH}'
# 'OS=${HOST_OS}'
# 'NATIVE_OS=${BUILD_OS}'
EXTRA_OEMAKE = "\
    'CC=${CC}' \
    'CPP=${CPP}' \
    'CXX=${CXX}' \
    'LD=${LD}' \
    \
    'NATIVE_CC=${BUILD_CC}' \
    \
    'CROSS_COMPILE=${HOST_PREFIX}' \
    \
    'CFLAGS_CMDLINE=${CFLAGS}' \
    'CFLAGS_DEBUG=' \
    'LDFLAGS_CMDLINE=${LDFLAGS}' \
    'LDFLAGS_DEBUG=' \
"
# --arch, --compiler, --toolchain, --sysroot, --cross-compile
# BUILD
# HOST
# TARGET
# ARCH
# COMPILER
# TOOLCHAIN
# SYSROOT
# CROSS_COMPILE
# SHELL

# CFLAGS
# CFLAGS_DEBUG
# CFLAGS_COMMON
# CFLAGS_CMDLINE
# CFLAGS_CONFIG
# CFLAGS_SYSROOT
# CFLAGS_PATH

# LDFLAGS
# LDFLAGS_DEBUG
# LDFLAGS_COMMON
# LDFLAGS_CMDLINE
# LDFLAGS_CONFIG
# LDFLAGS_SYSROOT
# LDFLAGS_PATH

# PE_SUBSYSTEM
# PE_IMAGE_BASE
# PE_CONFIG_DEFS

# ELF_EH_FRAME
# ELF_HASH_STYLE
# ELF_CONFIG_DEFS

# NATIVE_CC
# NATIVE_OS
# NATIVE_OS_BITS
# NATIVE_OS_UNDERSCORE
