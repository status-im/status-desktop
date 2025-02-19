#!/bin/sh
set -ef pipefail

CWD=$(realpath `dirname $0`)

ARCH=${ARCH:=amd64}
SDK=${SDK:=iphonesimulator}
JAVA_HOME=${JAVA_HOME}
BIN_DIR=${BIN_DIR:="$CWD/../bin"}
BUILD_DIR=${BUILD_DIR:="$CWD/../build"}
ANDROID_ABI=${ANDROID_ABI:="arm64-v8a"}

echo "Building wrapperApp for $OS, $ANDROID_ABI"

mkdir -p $BUILD_DIR
cd $BUILD_DIR

echo "Building wrapperApp"

if [ "$OS" = "android" ]; then

    if [ "$JAVA_HOME" = ""]; then
        echo "JAVA_HOME is not set. Please set JAVA_HOME to the path of your JDK 11 or later."
        exit 1
    fi

    qmake $CWD/../wrapperApp/IOS-build.pro CONFIG+=debug CONFIG+=device -spec android-clang ANDROID_ABIS="$ANDROID_ABI"

    # Build the app
    make  -j$(nproc) apk

    mkdir -p $BIN_DIR
    cp ./android-build/IOS-build.apk $BIN_DIR/IOS-build.apk

    echo "Build succeeded. APK is available at $BIN_DIR/IOS-build.apk"
else
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
fi