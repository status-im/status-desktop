#!/bin/sh
set -ef pipefail

CWD=$(realpath `dirname $0`)
ARCH=${ARCH:=amd64}
SDK=${SDK:=iphonesimulator}

mkdir -p $CWD/../build
cd $CWD/../build

echo "Building wrapperApp for IOS"

qmake $CWD/../wrapperApp/IOS-build.pro -spec macx-ios-clang CONFIG+=release CONFIG+=$SDK CONFIG+=device -after

# Compile resources
xcodebuild -configuration Release -target "Qt Preprocess" -sdk $SDK -arch $ARCH
# Compile the app
xcodebuild -configuration Release -target IOS-build install -sdk $SDK -arch $ARCH DSTROOT="$CWD/../bin"

if [ -e $CWD/../bin/Applications/IOS-build.app/Info.plist ]; then
    echo "Build succeeded"
else
    echo "Build failed"
    exit 1
fi