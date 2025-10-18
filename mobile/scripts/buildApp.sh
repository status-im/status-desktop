#!/usr/bin/env bash
set -ef pipefail

CWD=$(realpath "$(dirname "$0")")

ARCH=${ARCH:-amd64}
SDK=${SDK:-iphonesimulator}
JAVA_HOME=${JAVA_HOME:-}
BIN_DIR=${BIN_DIR:-"$CWD/../bin/ios"}
BUILD_DIR=${BUILD_DIR:-"$CWD/../build"}
ANDROID_ABI=${ANDROID_ABI:-"arm64-v8a"}
BUILD_TYPE=${BUILD_TYPE:-"apk"}

echo "Building wrapperApp for ${OS}, ${ANDROID_ABI}"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "Building wrapperApp"

if [[ "${OS}" == "android" ]]; then
  if [[ -z "${JAVA_HOME}" ]]; then
    echo "JAVA_HOME is not set. Please set JAVA_HOME to the path of your JDK 11 or later."
    exit 1
  fi

  echo "Building for Android 35"
  ANDROID_PLATFORM=android-35

  QMAKE_CONFIG="CONFIG+=device CONFIG+=release"
  QMAKE_BIN="${QMAKE:-qmake}"
  "$QMAKE_BIN" "$CWD/../wrapperApp/Status.pro" "$QMAKE_CONFIG" -spec android-clang ANDROID_ABIS="$ANDROID_ABI" APP_VARIANT="${APP_VARIANT}" -after

  # Build the app
  make -j"$(nproc)" apk_install_target

  if [[ "$BUILD_TYPE" == "aab" ]]; then
    if [[ -z "$KEYSTORE_PATH" || -z "$KEYSTORE_PASSWORD" || -z "$KEY_ALIAS" || -z "$KEY_PASSWORD" ]]; then
      echo "Error: AAB builds require signing credentials"
      echo "Required: KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD"
      exit 1
    fi

    if [[ ! -f "$KEYSTORE_PATH" ]]; then
      echo "Error: Keystore file not found at $KEYSTORE_PATH"
      exit 1
    fi

    echo "Building signed AAB..."
    androiddeployqt \
      --input "$BUILD_DIR/android-Status-deployment-settings.json" \
      --output "$BUILD_DIR/android-build" \
      --aab \
      --release \
      --android-platform "$ANDROID_PLATFORM" \
      --sign "$KEYSTORE_PATH" "$KEY_ALIAS" \
      --storepass "$KEYSTORE_PASSWORD" \
      --keypass "$KEY_PASSWORD"

    OUTPUT_FILE=$(find "$BUILD_DIR/android-build/build/outputs/bundle" -name "*.aab" | head -n 1)
    if [[ ! -f "$OUTPUT_FILE" ]]; then
      echo "Error: Could not find generated AAB file"
      exit 1
    fi

    ANDROID_OUTPUT_DIR="bin/android/qt6"
    BIN_DIR_ANDROID=${BIN_DIR:-"$CWD/$ANDROID_OUTPUT_DIR"}
    mkdir -p "$BIN_DIR_ANDROID"
    cp "$OUTPUT_FILE" "$BIN_DIR_ANDROID/Status.aab"
    echo "Build succeeded. Signed AAB is available at $BIN_DIR_ANDROID/Status.aab"
  else
    # APK build
    NEEDS_SIGNING="false"
    if [[ -n "$KEYSTORE_PATH" && -n "$KEYSTORE_PASSWORD" && -n "$KEY_ALIAS" && -n "$KEY_PASSWORD" ]]; then
      if [[ -f "$KEYSTORE_PATH" ]]; then
        NEEDS_SIGNING="true"
      fi
    fi

    if [[ "$NEEDS_SIGNING" == "true" ]]; then
      echo "Building signed APK..."
      androiddeployqt \
        --input "$BUILD_DIR/android-Status-deployment-settings.json" \
        --output "$BUILD_DIR/android-build" \
        --apk "$BUILD_DIR/android-build/Status.apk" \
        --release \
        --android-platform "$ANDROID_PLATFORM" \
        --sign "$KEYSTORE_PATH" "$KEY_ALIAS" \
        --storepass "$KEYSTORE_PASSWORD" \
        --keypass "$KEY_PASSWORD"
    else
      echo "Building unsigned APK..."
      androiddeployqt \
        --input "$BUILD_DIR/android-Status-deployment-settings.json" \
        --output "$BUILD_DIR/android-build" \
        --apk "$BUILD_DIR/android-build/Status.apk" \
        --android-platform "$ANDROID_PLATFORM"
    fi

    ANDROID_OUTPUT_DIR="bin/android/qt6"
    BIN_DIR_ANDROID=${BIN_DIR:-"$CWD/$ANDROID_OUTPUT_DIR"}
    mkdir -p "$BIN_DIR_ANDROID"
    cp ./android-build/Status.apk "$BIN_DIR_ANDROID/Status.apk"

    if [[ "$NEEDS_SIGNING" == "true" ]]; then
      echo "Build succeeded. Signed APK is available at $BIN_DIR_ANDROID/Status.apk"
    else
      echo "Build succeeded. Unsigned APK is available at $BIN_DIR_ANDROID/Status.apk"
    fi
  fi
else
  QMAKE_BIN="${QMAKE:-qmake}"
  "$QMAKE_BIN" "$CWD/../wrapperApp/Status.pro" -spec macx-ios-clang CONFIG+=release CONFIG+="$SDK" CONFIG+=device -after
  # Compile resources
  xcodebuild -configuration Release -target "Qt Preprocess" -sdk "$SDK" -arch "$ARCH" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO | xcbeautify
  # Compile the app
  xcodebuild -configuration Release -target Status install -sdk "$SDK" -arch "$ARCH" DSTROOT="$BIN_DIR" INSTALL_PATH="/" TARGET_BUILD_DIR="$BIN_DIR" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO | xcbeautify

  if [[ -e "$BIN_DIR/Status.app/Info.plist" ]]; then
    echo "Build succeeded"
  else
    echo "Build failed"
    exit 1
  fi
fi
