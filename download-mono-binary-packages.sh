#!/bin/bash
set -u
set -e
set +x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$SCRIPT_DIR/build"
OUT_DIR="$SCRIPT_DIR/out"

mkdir -p "$OUT_DIR"

cd "$OUT_DIR"

wget -c https://download.mono-project.com/repo/centos7-stable/libg/libgdiplus0/libgdiplus-devel-5.6-0.xamarin.1.epel7.x86_64.rpm
wget -c https://download.mono-project.com/repo/centos7-stable/libg/libgdiplus0/libgdiplus0-5.6-0.xamarin.1.epel7.src.rpm
wget -c https://download.mono-project.com/repo/centos7-stable/libg/libgdiplus0/libgdiplus0-debuginfo-5.6-0.xamarin.1.epel7.x86_64.rpm
wget -c https://download.mono-project.com/repo/centos7-stable/libg/libgdiplus0/libgdiplus0-5.6-0.xamarin.1.epel7.x86_64.rpm
