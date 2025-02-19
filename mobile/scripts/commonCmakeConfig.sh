#!/bin/sh
ARCH=${ARCH:="x86_64"}
QTDIR=${QTDIR:="/usr/local/opt/qt"}
OS=${OS:=ios}
ANDROID_NDK_HOME=${ANDROID_NDK_HOME:=""}

STATIC_LIB=ON
CMAKE_TOOLCHAIN_FILE=""

if [ "$OS" = "ios" ]; then
    if [ "$ARCH" = "x86_64" ]; then
        SDK="iphonesimulator"
    else
        SDK="iphoneos"
    fi
    SYSTEM_NAME="iOS"
    IOS_CONFIG="-DCMAKE_OSX_ARCHITECTURES:STRING=$ARCH \
        -DCMAKE_OSX_SYSROOT=$SDK \
        -DCMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=12.0"

elif [ "$OS" = "android" ]; then
    if [ "$ARCH" = "arm64" ]; then
        ANDROID_ABI="arm64-v8a"
    elif [ "$ARCH" = "arm" ]; then
        ANDROID_ABI="armeabi-v7a"
    fi
    SYSTEM_NAME="Android"
    STATIC_LIB=OFF
    CMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
    ANDROID_CONFIG="-DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
                        -DANDROID_ABI:STRING=$ANDROID_ABI"
else
    echo "Unknown OS: $OS"
    exit 1
fi

COMMON_CMAKE_CONFIG="$ANDROID_CONFIG \
    $IOS_CONFIG \
    -DCMAKE_SYSTEM_NAME:STRING=$SYSTEM_NAME \
    -DCMAKE_FIND_ROOT_PATH:STRING=$QTDIR \
    -DCMAKE_BUILD_TYPE=Release"

echo $COMMON_CMAKE_CONFIG
