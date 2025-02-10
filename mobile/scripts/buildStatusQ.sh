#!/bin/sh
set -ef pipefail

ARCH=${ARCH:="x86_64"}
SDK=${SDK:="iphonesimulator"}

echo "Building StatusQ for $ARCH using compiler: $CC"

cmake -S ./ -B build \
    -DCMAKE_GENERATOR:STRING=Xcode \
    -DCMAKE_SYSTEM_NAME:STRING=iOS \
    -DCMAKE_OSX_ARCHITECTURES:STRING=$ARCH \
    -DCMAKE_FIND_ROOT_PATH:STRING=$QTDIR \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_SYSROOT=$SDK \
    -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=12.0 \
    -DSTATUSQ_BUILD_SANDBOX=OFF \
    -DSTATUSQ_BUILD_SANITY_CHECKER=OFF \
    -DSTATUSQ_BUILD_TESTS=OFF \
    -DSTATUSQ_STATIC_LIB=ON
    
cmake --build build --target StatusQ --config Release --parallel 10