#!/bin/bash
set -u
set -e
set +x

if [[ "$#" != "1" ]]; then
    echo "Incorrect number of arguments: $#" >&2
    echo "Usage: $0 xsp_dir" >&2
    exit 1
fi

XSP_DIR="$1"

if [[ ! -d "$XSP_DIR" ]]; then
    echo "'$XSP_DIR' does not exists or is not a directory" >&2
    exit 1
fi

if [[ ! -d "$XSP_DIR/.git" ]]; then
    echo "'$XSP_DIR/.git' does not exists or is not a directory" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$SCRIPT_DIR/build"
OUT_DIR="$SCRIPT_DIR/out"

echo "Building RPM packages from:"
echo "mono: $XSP_DIR"
echo "working directory: $WORK_DIR"
echo "output directory: $OUT_DIR"

# MONO_MAJOR_VER is triplet like 5.23.0 (actually, it contains major, minor and patch version numbers).
# It is extracted from autoconf script:
# AC_INIT(mono, [5.23.0],
XSP_MAJOR_VER="$(cd "$XSP_DIR" && cat "configure.ac" | grep -E 'AC_INIT\(\[xsp\],' | sed -e 's/AC_INIT(\[xsp\], \[\([^]]*\)\].*/\1/')"
# MONO_MINOR_VER is commit count since setting MAJOR_VER
# It can be calculated from git history in a hacky way (count of commits since current version appeared in configure.ac)
XSP_MINOR_VER="$(cd "$XSP_DIR" && git log $(git log -S "$XSP_MAJOR_VER" --format='%H' configure.ac | head -n 1)..HEAD --format='%H' | wc -l)"

echo "major version: $XSP_MAJOR_VER"
echo "minor version: $XSP_MINOR_VER"

rm -rf "$WORK_DIR"
rm -rf "$OUT_DIR/*"

mkdir -p "$WORK_DIR"
mkdir -p "$OUT_DIR"

cp -r "$(dirname "$0")/linux-packaging-xsp" "$WORK_DIR"

sed -i "$WORK_DIR/linux-packaging-xsp/xsp.spec" \
   -e "s/Version:.*/Version: $XSP_MAJOR_VER.$XSP_MINOR_VER/" \
   -e "s/Release:.*/Release: 0.bars/" \
   -e 's/.\/configure \(.*\)/.\/autogen.sh \1/'

SRC_TAR_DIR="$WORK_DIR/srcbuild/xsp-$XSP_MAJOR_VER.$XSP_MINOR_VER"

mkdir -p "$SRC_TAR_DIR"

(
    cd "$XSP_DIR" &&

    git archive --format tar HEAD | (cd "$SRC_TAR_DIR" && tar xf -)
)

(
    cd "$WORK_DIR/srcbuild" &&
    tar czf "xsp-$XSP_MAJOR_VER.$XSP_MINOR_VER.tar.gz" "xsp-$XSP_MAJOR_VER.$XSP_MINOR_VER"
)

cp "$WORK_DIR/srcbuild/xsp-$XSP_MAJOR_VER.$XSP_MINOR_VER.tar.gz" "$WORK_DIR/linux-packaging-xsp/xsp-$XSP_MAJOR_VER.$XSP_MINOR_VER.tar.gz"

(
    cd "$WORK_DIR/linux-packaging-xsp" &&
    tar cvf srcrpm.tar * &&
    rpmbuild -ts srcrpm.tar --define "_topdir $(pwd)"
)

cp "$WORK_DIR/linux-packaging-xsp/SRPMS/"*.src.rpm "$WORK_DIR"
cp "$WORK_DIR/linux-packaging-xsp/SRPMS/"*.src.rpm "$OUT_DIR"
