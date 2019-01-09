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
WORK_DIR="$SCRIPT_DIR/build"
OUT_DIR="$SCRIPT_DIR/out"

echo "Building RPM packages from:"
echo "mono: $MONO_DIR"
echo "working directory: $WORK_DIR"
echo "output directory: $OUT_DIR"

# MONO_MAJOR_VER is triplet like 5.23.0 (actually, it contains major, minor and patch version numbers).
# It is extracted from autoconf script:
# AC_INIT(mono, [5.23.0],
MONO_MAJOR_VER="$(cd "$MONO_DIR" && cat "configure.ac" | grep -E 'AC_INIT\(mono,' | sed -e 's/AC_INIT(mono, \[\([^]]*\)\].*/\1/')"
# MONO_MINOR_VER is commit count since setting MAJOR_VER
# It can be calculated from git history in a hacky way (count of commits since current version appeared in configure.ac)
MONO_MINOR_VER="$(cd "$MONO_DIR" && git log $(git log -S "$MONO_MAJOR_VER" --format='%H' configure.ac | head -n 1)..HEAD --format='%H' | wc -l)"

echo "major version: $MONO_MAJOR_VER"
echo "minor version: $MONO_MINOR_VER"

rm -rf "$WORK_DIR"
rm -rf "$OUT_DIR"

mkdir -p "$WORK_DIR"
mkdir -p "$OUT_DIR"

cp -r "$(dirname "$0")/linux-packaging-mono" "$WORK_DIR"

sed -i "$WORK_DIR/linux-packaging-mono/mono-core.spec" \
    -e "s/%define __majorver .*/%define __majorver $MONO_MAJOR_VER/" \
    -e "s/%define __minorver .*/%define __minorver $MONO_MINOR_VER/" \
    -e "s/Release:.*/Release: 0.bars/" \
    -e "s/%define llvm .*/%define llvm no/"

SRC_TAR_DIR="$WORK_DIR/srcbuild/mono-$MONO_MAJOR_VER.$MONO_MINOR_VER"

mkdir -p "$SRC_TAR_DIR"

(
    # `monolite` is needed for bootstrapping mono without existing mono installation
    EXTRACTED_MONO_CORLIB_VERSION="$(cat "$MONO_DIR/configure.ac" | grep -E '^MONO_CORLIB_VERSION=' | sed -e 's/MONO_CORLIB_VERSION=\(.*\)/\1/')"

    cd "$MONO_DIR" &&
    (cd mcs/class && make get-monolite-latest MONO_CORLIB_VERSION="$EXTRACTED_MONO_CORLIB_VERSION" BUILD_PLATFORM=linux) &&
    mkdir -p "$SRC_TAR_DIR/mcs/class/lib" &&
    cp -r mcs/class/lib/monolite-linux "$SRC_TAR_DIR/mcs/class/lib"
)

(
    cd "$MONO_DIR" &&

    # next two commands create .tar.bz2 from git repository with recursive submodules
    git archive --format tar HEAD | (cd "$SRC_TAR_DIR" && tar xf -) &&
    git submodule status --recursive | awk '{print $2}' |
        while read DIR; do
            (
                (cd $DIR && git archive --format tar --prefix "$DIR/" HEAD) | (cd "$SRC_TAR_DIR" && tar xf -)
            )
        done
)

(
    cd "$WORK_DIR/srcbuild" &&
    tar cjf "mono-$MONO_MAJOR_VER.$MONO_MINOR_VER.tar.bz2" "mono-$MONO_MAJOR_VER.$MONO_MINOR_VER"
)

cp "$WORK_DIR/srcbuild/mono-$MONO_MAJOR_VER.$MONO_MINOR_VER.tar.bz2" "$WORK_DIR/linux-packaging-mono/mono-$MONO_MAJOR_VER.$MONO_MINOR_VER.tar.bz2"

(
    cd "$WORK_DIR/linux-packaging-mono" &&
    tar cvf srcrpm.tar * &&
    rpmbuild -ts srcrpm.tar --define "_topdir $(pwd)"
)

cp "$WORK_DIR/linux-packaging-mono/SRPMS/"*.src.rpm "$WORK_DIR"
cp "$WORK_DIR/linux-packaging-mono/SRPMS/"*.src.rpm "$OUT_DIR"
