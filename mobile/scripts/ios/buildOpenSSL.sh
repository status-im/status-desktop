#!/usr/bin/env bash
set -ef pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OPENSSL=${OPENSSL:-"../vendors/openssl"}
OS=${OS:-"ios"}
ARCH=${ARCH:-"x86_64"}
SDK=${SDK:-"iphonesimulator"}
LIB_PATH=${LIB_PATH:-"../lib/ios"}
LIB_EXT=${LIB_EXT:-".a"}
ANDROID_API=${ANDROID_API:-28}
BUILD_DIR=${BUILD_DIR:-"build-${TARGET}"}

TARGET="${OS}-${ARCH}"
SSL_BUILD_DIR=${BUILD_DIR}/openssl-${TARGET}
CRYPTO_OUTPUT_LIB=${LIB_PATH}/libcrypto_3${LIB_EXT}
SSL_OUTPUT_LIB=${LIB_PATH}/libssl_3${LIB_EXT}

PLATFORM_ARGS=""

if [[ "$OS" == "ios" ]]; then
    if [[ "$SDK" == "iphonesimulator" ]]; then
        case ${ARCH} in
            "x86_64") TARGET="iossimulator-x86_64-xcrun";;
            "arm64")  TARGET="iossimulator-arm64-xcrun";;
            "x86")    TARGET="iossimulator-i386-xcrun";;
            # default to system architecture
            # missing armv7 support for ios simulator
            *)        TARGET="iossimulator-xcrun";;
        esac
    elif [[ "$SDK" == "iphoneos" ]]; then
        case ${ARCH} in
            "arm64")  TARGET="ios64-xcrun";;
            *)        TARGET="ios-xcrun";;
        esac
    fi
fi

if [[ "$OS" == "android" ]]; then
    PLATFORM_CONFIG_ARGS="-U__ANDROID_API__ -D__ANDROID_API__=${ANDROID_API}"
    PLATFORM_BUILD_ARGS="SHLIB_VERSION_NUMBER="
    cleanup() {
        if [[ "$OS" == "android" ]]; then
            patch -d ${OPENSSL} -R -p0 < "${SCRIPT_DIR}/openssl-patch.diff"
        fi
    }

    trap cleanup EXIT
    patch -d ${OPENSSL} -p0 < "${SCRIPT_DIR}/openssl-patch.diff"
fi

echo "Building OpenSSL for $TARGET with platform config args $PLATFORM_CONFIG_ARGS"

mkdir -p ${SSL_BUILD_DIR}

(
    cd ${SSL_BUILD_DIR}
    ${OPENSSL}/Configure --release "$TARGET" $PLATFORM_CONFIG_ARGS
    # Rebuilding isn't working with the default target, so we need to clean and build again
    make clean
    make -j$(sysctl -n hw.ncpu) $PLATFORM_BUILD_ARGS build_libs
)

echo "Copying $CRYPTO_OUTPUT_LIB and $SSL_OUTPUT_LIB to $LIB_PATH"
cp "${SSL_BUILD_DIR}/libcrypto${LIB_EXT}" "$CRYPTO_OUTPUT_LIB"
cp "${SSL_BUILD_DIR}/libssl${LIB_EXT}" "$SSL_OUTPUT_LIB"

if [[ "$LIB_EXT" == ".so" ]]; then
    # Just in case this lands in a qt5 build, strip the unneeded symbols
    # Qt6 androidDeployQt will strip it by default.
    HOST_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${HOST_OS}-x86_64/bin/llvm-strip --strip-all $CRYPTO_OUTPUT_LIB
    ${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${HOST_OS}-x86_64/bin/llvm-strip --strip-all $SSL_OUTPUT_LIB
fi