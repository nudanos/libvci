#!/bin/sh
# SPDX-License-Identifier: LGPL-2.1-only
# The language bindings must record libvci.so.1 as NEEDED. Debian 13 links
# with --as-needed, which drops a library named before the objects that
# use it: the Perl binding was linked "-lvci vci_wrap.cxx", recorded no
# dependency, and failed to load ("undefined symbol: vci::Client::emit"),
# breaking every Perl configuration script that uses VCI (bonding).
set -eu
fail=0
for so in "${1:-swig/perl5/vci.so}" "${2:-swig/python3/_vci.so}"; do
    [ -f "$so" ] || { echo "bindings-linked: $so not built" >&2; fail=1; continue; }
    if ! readelf -d "$so" | grep -q 'NEEDED.*\[libvci\.so\.1\]'; then
        echo "bindings-linked: $so does not record libvci.so.1 as NEEDED" >&2
        fail=1
    fi
done
[ $fail = 0 ] && echo "bindings-linked: OK"
exit $fail
