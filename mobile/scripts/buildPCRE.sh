#!/bin/sh

ARCH=${ARCH:=amd64}

echo "Building PCRE for $ARCH using compiler: $CC"

cmake -S ./ -B build \
    -DCMAKE_GENERATOR:STRING=Xcode \
    -DCMAKE_SYSTEM_NAME:STRING=iOS \
    -DCMAKE_OSX_ARCHITECTURES:STRING=$ARCH \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_SYSROOT=iphonesimulator \
    -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=12.0 \
    -DPCRE_BUILD_TESTS:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DCMAKE_CXX_COMPILER:STRING=$CXX \
    -DCMAKE_C_COMPILER:STRING=$CC \
    -DPCRE_BUILD_PCREGREP:BOOL=OFF

cmake --build build --target pcre --config Release --parallel 10 2>&1
