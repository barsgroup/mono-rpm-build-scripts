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
wget -c https://download.mono-project.com/repo/centos7-stable/m/msbuild/msbuild-sdkresolver-16.3+xamarinxplat.2019.08.08.00.55-0.xamarin.2.epel7.noarch.rpm
wget -c https://download.mono-project.com/repo/centos7-stable/m/msbuild/msbuild-16.3+xamarinxplat.2019.08.08.00.55-0.xamarin.2.epel7.noarch.rpm
wget -c https://download.mono-project.com/repo/centos7-stable/m/msbuild-libhostfxr/msbuild-libhostfxr-3.0.0.2019.04.16.02.13-0.xamarin.4.epel7.x86_64.rpm