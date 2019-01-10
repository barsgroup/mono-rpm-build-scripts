#!/bin/bash
set -u
set -e
set +x

# TODO:
# 1) поддерживать llvm-mono

if [[ "$#" != "1" ]]; then
    echo "Incorrect number of arguments: $#" >&2
    echo "Usage: $0 mono_dir" >&2
    exit 1
fi

MONO_DIR="$1"

if [[ ! -d "$MONO_DIR" ]]; then
    echo "'$MONO_DIR' does not exists or is not a directory" >&2
    exit 1
fi

if [[ ! -d "$MONO_DIR/.git" ]]; then
    echo "'$MONO_DIR/.git' does not exists or is not a directory" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/out"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

docker run --rm -it -v "$MONO_DIR":/work/mono-src -v "$SCRIPT_DIR":/work/scripts centos:7 sh -c '
yum -y install epel-release &&
yum -y install git make bzip2 rpm-build &&
/work/scripts/make-srpm-from-git-checkout.sh /work/mono-src &&
yum-builddep -y /work/scripts/out/mono-core-*.src.rpm &&
rpmbuild --rebuild /work/scripts/out/mono-core-*.src.rpm &&
cp ~/rpmbuild/RPMS/x86_64/*.rpm /work/scripts/out/
'
