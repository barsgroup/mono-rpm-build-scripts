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

"$SCRIPT_DIR/make-srpm-from-git-checkout.sh" "$MONO_DIR"
mock -r epel-7-x86_64 --resultdir="$OUT_DIR" "$SCRIPT_DIR/out/mono-core-*.src.rpm"