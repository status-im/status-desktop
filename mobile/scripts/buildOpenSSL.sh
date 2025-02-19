#!/bin/sh
set -ef pipefail

ARCH=${ARCH:="x86_64"}
SDK=${SDK:="iphonesimulator"}
IOS_TARGET=${IOS_TARGET:=12}
LIB_PATH=${LIB_PATH:="../lib/ios"}

TARGET="ios"
CRYPTO_OUTPUT_LIB=lib/libcrypto-IOS.a
SSL_OUTPUT_LIB=lib/libssl-IOS.a

if [ "$SDK" = "iphonesimulator" ]; then
    TARGET=$TARGET"-sim"
    CRYPTO_OUTPUT_LIB=lib/libcrypto-IOS-Sim.a
    SSL_OUTPUT_LIB=lib/libssl-IOS-Sim.a
fi

TARGET=$TARGET"-cross-$ARCH"

echo "Building OpenSSL for $TARGET with SDK version $IOS_TARGET"

./build-libssl.sh --targets=$TARGET --ios-min-sdk=$IOS_TARGET 

echo "Copying $OUTPUT_LIB to $LIB_PATH"
cp $CRYPTO_OUTPUT_LIB $LIB_PATH/libcrypto_1_1.a
cp $SSL_OUTPUT_LIB $LIB_PATH/libssl_1_1.a