#!/bin/sh

SDK_PATH=${SDK_PATH:=""}
ANDROID_NDK_HOME=${ANDROID_NDK_HOME:=""}
ANDROID_API=${ANDROID_API:=28}
ARCH=${ARCH:="arm64"}

HOST_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
CLANG=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/$HOST_OS-x86_64/bin/clang
SYSROOT=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/$HOST_OS-x86_64/sysroot

TARGET_SUFFIX=""

if [ "$ARCH" == "amd64" ]; then
    CARCH="x86_64"
elif [ "$ARCH" == "arm64" ]; then
    CARCH="aarch64"
elif [ "$ARCH" == "arm" ]; then
    CARCH="armv7a"
    TARGET_SUFFIX="eabi"
elif [ "$ARCH" == "386" ]; then
    CARCH="i686"
else
    CARCH="$ARCH"
fi

TARGET="$CARCH-linux-android${TARGET_SUFFIX}${ANDROID_API}"
EXTRA_ARGS="-fembed-bitcode"

exec $CLANG --target=$TARGET $EXTRA_ARGS --sysroot=$SYSROOT -v "$@"