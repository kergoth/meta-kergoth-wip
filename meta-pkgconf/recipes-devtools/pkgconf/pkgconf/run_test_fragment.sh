#!/bin/bash
#
# Copyright (c) 2012 Michał Górny <mgorny@gentoo.org>.
# Copyright (c) 2015 Christopher Larson <kergoth@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# This software is provided 'as is' and without any warranty, express or
# implied.  In no event shall the authors be liable for any damages arising
# from the use of this software.

run_test() {
	local res t_ret 2>/dev/null || true
	local cmdline 2>/dev/null || true

	cmdline="${1}"

	eval res="\$(${1})" 2>/dev/null

	t_ret=0
	while [ ${#} -gt 1 ]; do
		shift

		case "${res}" in
			*"${1}"*)
				;;
			*)
				t_ret=1
				;;
		esac
	done

	if [ ${t_ret} -eq 0 ]; then
		echo "PASS: $cmdline"
	else
		echo "FAIL: $cmdline"
	fi
}

if [ $# -eq 0 ]; then
    set -- pkgconf
fi
