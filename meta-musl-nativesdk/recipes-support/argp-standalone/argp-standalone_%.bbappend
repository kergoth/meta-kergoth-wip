# CFLAGS += gets blown away when nativesdk is inherited afterward, so use
# _append to postpone it.
CFLAGS_append = " -fPIC -U__OPTIMIZE__"

BBCLASSEXTEND += "nativesdk"
