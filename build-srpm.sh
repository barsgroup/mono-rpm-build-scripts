#!/bin/bash
set -u
set -e
set +x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/out"
MONO_SRPMS=($OUT_DIR/mono-core-*.src.rpm)
MONO_SRPM="${MONO_SRPMS[0]}"

echo "Building RPM packages from SRPM $MONO_SRPM"

# mock --new-chroot (which is the default) uses systemd-nspawn which does not work in docker
mock -r epel-7-x86_64 --old-chroot --resultdir="$OUT_DIR" "$MONO_SRPM"
