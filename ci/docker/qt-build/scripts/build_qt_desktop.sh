#!/bin/bash

#
# Build script for Qt 6.9.0 Desktop (amd64 only) - Status Team Version
# This is only needed as host Qt for Android cross-compilation
#

set -e

qt_version="6.9.0"

echo "Building host Qt ${qt_version} for Android cross-compilation..."

cd /root
if [ ! -d "qt5" ]; then
    git clone https://code.qt.io/qt/qt5.git
    cd qt5
    git checkout v$qt_version
    perl init-repository
else
    cd qt5
    git checkout v$qt_version
    git submodule foreach --recursive git reset --hard
    git submodule foreach --recursive git clean -dxf
    git submodule update --init --recursive
fi

mkdir -p /root/build-amd64
cd /root/build-amd64
/root/qt5/configure -verbose -release -nomake examples -nomake tests \
    -prefix /opt/qt/$qt_version/gcc_64 \
    -skip qtwebengine
cmake --build . --parallel $(($(nproc)+4))
cmake --install .

cd /opt/qt/$qt_version
tar cvfpJ /root/export/Qt-amd64-$qt_version.tar.xz gcc_64

echo "Host Qt ${qt_version} build complete!"
