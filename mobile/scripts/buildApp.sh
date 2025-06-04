#!/usr/bin/env bash
set -ef pipefail

CWD=$(realpath "$(dirname "$0")")

ARCH=${ARCH:-amd64}
SDK=${SDK:-iphonesimulator}
JAVA_HOME=${JAVA_HOME:-}
BIN_DIR=${BIN_DIR:-"$CWD/../bin/ios"}
BUILD_DIR=${BUILD_DIR:-"$CWD/../build"}
ANDROID_ABI=${ANDROID_ABI:-"arm64-v8a"}
QT_MAJOR=${QT_MAJOR:-"5"}

echo "Building wrapperApp for ${OS}, ${ANDROID_ABI}"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "Building wrapperApp"

if [[ "${QT_MAJOR}" == "6" ]]; then
    COMPAT_RESOURCES=compat_resources.qrc
fi

if [[ "${OS}" == "android" ]]; then
    if [[ -z "${JAVA_HOME}" ]]; then
        echo "JAVA_HOME is not set. Please set JAVA_HOME to the path of your JDK 11 or later."
        exit 1
    fi

    if [[ "${QT_MAJOR}" == "5" ]]; then
        echo "Building for Android 31"
        ANDROID_PLATFORM=android-31
    elif [[ "${QT_MAJOR}" == "6" ]]; then
        echo "Building for Android 35"
        ANDROID_PLATFORM=android-35
    else
        echo "Invalid QT_MAJOR. Please set QT_MAJOR to 5 or 6."
        exit 1
    fi

    qmake "$CWD/../wrapperApp/Status-tablet.pro" CONFIG+=device CONFIG+=release RESOURCES+="$COMPAT_RESOURCES" -spec android-clang ANDROID_ABIS="$ANDROID_ABI" -after

    # Build the app
    make -j"$(nproc)" apk_install_target

    # call androiddeployqt
    androiddeployqt --input "$BUILD_DIR/android-Status-tablet-deployment-settings.json" --output "$BUILD_DIR/android-build" --apk "$BUILD_DIR/android-build/Status-tablet.apk" --android-platform "$ANDROID_PLATFORM"

    mkdir -p "$BIN_DIR"
    cp ./android-build/Status-tablet.apk "$BIN_DIR/Status-tablet.apk"

    echo "Build succeeded. APK is available at $BIN_DIR/Status-tablet.apk"
else
    qmake "$CWD/../wrapperApp/Status-tablet.pro" RESOURCES+="$COMPAT_RESOURCES" -spec macx-ios-clang CONFIG+=release CONFIG+="$SDK" CONFIG+=device -after
    # Compile resources
    xcodebuild -configuration Release -target "Qt Preprocess" -sdk "$SDK" -arch "$ARCH"
    # Compile the app
    xcodebuild -configuration Release -target Status-tablet install -sdk "$SDK" -arch "$ARCH" DSTROOT="$BIN_DIR" INSTALL_PATH="/" TARGET_BUILD_DIR="$BIN_DIR" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

    if [[ -e "$BIN_DIR/Status-tablet.app/Info.plist" ]]; then
        echo "Build succeeded"
    else
        echo "Build failed"
        exit 1
    fi
fi