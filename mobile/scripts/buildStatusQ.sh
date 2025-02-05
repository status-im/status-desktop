#!/bin/sh

#Make sure CC is properly set
#CC=clangwrap.sh
#CXX=clangwrap.sh

ARCH=${ARCH:="x86_64"}

export CC=$CC
export CXX=$CXX

echo "Building StatusQ for $ARCH using compiler: $CC"

cmake -S ./ -B build \
    -DCMAKE_GENERATOR:STRING=Xcode \
    -DCMAKE_SYSTEM_NAME:STRING=iOS \
    -DCMAKE_OSX_ARCHITECTURES:STRING=$ARCH \
    -DCMAKE_FIND_ROOT_PATH:STRING=/Users/alexjbanca/Qt/5.15.2/ios \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_SYSROOT=iphonesimulator \
    -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=12.0 \
    -DSTATUSQ_BUILD_SANDBOX=OFF \
    -DSTATUSQ_BUILD_SANITY_CHECKER=OFF \
    -DSTATUSQ_BUILD_TESTS=OFF \
    -DSTATUSQ_STATIC_LIB=ON 2>&1
    
cmake --build build --target StatusQ --config Release --parallel 10 2>&1