#!/bin/bash
set -u
set -e
set +x

# TODO:
# 1) поддерживать llvm-mono

if [[ "$#" != "2" ]]; then
    echo "Incorrect number of arguments: $#" >&2
    echo "Usage: $0 mono_dir xsp_dir" >&2
    exit 1
fi

MONO_DIR="$1"
XSP_DIR="$2"

if [[ ! -d "$MONO_DIR" ]]; then
    echo "'$MONO_DIR' does not exists or is not a directory" >&2
    exit 1
fi

if [[ ! -d "$MONO_DIR/.git" ]]; then
    echo "'$MONO_DIR/.git' does not exists or is not a directory" >&2
    exit 1
fi

if [[ ! -d "$XSP_DIR" ]]; then
    echo "'$XSP_DIR' does not exists or is not a directory" >&2
    exit 1
fi

if [[ ! -d "$XSP_DIR/.git" ]]; then
    echo "'$XSP_DIR/.git' does not exists or is not a directory" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/out"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

docker run --rm -it -v "$MONO_DIR":/work/mono-src -v "$XSP_DIR":/work/xsp-src -v "$SCRIPT_DIR":/work/scripts centos:7 sh -c '
yum -y install epel-release &&
yum -y install git make bzip2 rpm-build wget &&
/work/scripts/make-mono-srpm-from-git-checkout.sh /work/mono-src &&
/work/scripts/make-xsp-srpm-from-git-checkout.sh /work/xsp-src &&
yum-builddep -y /work/scripts/out/mono-core-*.src.rpm &&
rpmbuild --rebuild /work/scripts/out/mono-core-*.src.rpm &&
/work/scripts/download-mono-binary-packages.sh &&
cp -v ~/rpmbuild/RPMS/x86_64/*.rpm /work/scripts/out/ &&
rm -rf ~/rpmbuild/ &&
yum -y install /work/scripts/out/*.{x86_64,noarch}.rpm &&
yum-builddep -y /work/scripts/out/xsp-*.src.rpm &&
rpmbuild --rebuild /work/scripts/out/xsp-*.src.rpm &&
cp -v ~/rpmbuild/RPMS/x86_64/*.rpm /work/scripts/out/ &&
rm -rf ~/rpmbuild/
'
