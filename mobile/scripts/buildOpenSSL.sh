#!/bin/sh

ARCH=${ARCH:="x86_64"}
SDK=${SDK:="iphonesimulator"}
IOS_TARGET=${IOS_TARGET:=12}

TARGET="ios"

if [ "$SDK" = "iphonesimulator" ]; then
    TARGET=$TARGET"-sim"
fi

TARGET=$TARGET"-cross-$ARCH"

echo "Building OpenSSL for $TARGET with SDK version $IOS_TARGET"

./build-libssl.sh --targets=$TARGET --ios-min-sdk=$IOS_TARGET 2>&1