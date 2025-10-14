#!/usr/bin/env bash
set -ef pipefail

CWD=$(realpath "$(dirname "$0")")

ARCH=${ARCH:-amd64}
SDK=${SDK:-iphonesimulator}
JAVA_HOME=${JAVA_HOME:-}
BIN_DIR=${BIN_DIR:-"$CWD/../bin/ios"}
BUILD_DIR=${BUILD_DIR:-"$CWD/../build"}
ANDROID_ABI=${ANDROID_ABI:-"arm64-v8a"}
SIGN_IOS=${SIGN_IOS:-"false"}

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
    "$QMAKE_BIN" "$CWD/../wrapperApp/Status-tablet.pro" "$QMAKE_CONFIG" -spec android-clang ANDROID_ABIS="$ANDROID_ABI" APP_VARIANT="${APP_VARIANT}" -after

    # Build the app
    make -j"$(nproc)" apk_install_target

    # call androiddeployqt
    androiddeployqt --input "$BUILD_DIR/android-Status-tablet-deployment-settings.json" --output "$BUILD_DIR/android-build" --apk "$BUILD_DIR/android-build/Status-tablet.apk" --android-platform "$ANDROID_PLATFORM"
   
    ANDROID_OUTPUT_DIR="bin/android/qt6"
    BIN_DIR_ANDROID=${BIN_DIR:-"$CWD/$ANDROID_OUTPUT_DIR"}
    mkdir -p "$BIN_DIR_ANDROID"
    cp ./android-build/Status-tablet.apk "$BIN_DIR_ANDROID/Status-tablet.apk"

    echo "Build succeeded. APK is available at $BIN_DIR_ANDROID/Status-tablet.apk"
else
    QMAKE_BIN="${QMAKE:-qmake}"
    "$QMAKE_BIN" "$CWD/../wrapperApp/Status-tablet.pro" -spec macx-ios-clang CONFIG+=release CONFIG+="$SDK" CONFIG+=device -after

    # Compile resources
    xcodebuild -configuration Release -target "Qt Preprocess" -sdk "$SDK" -arch "$ARCH" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO | xcbeautify
    # Compile the app
    xcodebuild -configuration Release -target Status-tablet install -sdk "$SDK" -arch "$ARCH" DSTROOT="$BIN_DIR" INSTALL_PATH="/" TARGET_BUILD_DIR="$BIN_DIR" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO | xcbeautify

    if [[ ! -e "$BIN_DIR/Status-tablet.app/Info.plist" ]]; then
        echo "Build failed"
        exit 1
    fi

    if [[ "$SIGN_IOS" == "true" ]]; then
        echo "Signing iOS app..."

        if [[ -z "$IOS_CERT_PATH" || -z "$IOS_CERT_PASSWORD" || -z "$IOS_PROVISIONING_PROFILE" ]]; then
            echo "Error: Missing iOS signing credentials"
            exit 1
        fi

        # Import certificate to keychain
        KEYCHAIN_NAME="build.keychain"
        KEYCHAIN_PASSWORD=$(openssl rand -base64 16)

        # Cleanup function to delete keychain
        cleanup_keychain() {
            echo "Cleaning up keychain..."
            security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true
        }

        # Set trap to cleanup keychain on script exit (success or failure)
        trap cleanup_keychain EXIT

        # Delete any existing keychain from previous failed builds
        security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true

        security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
        security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
        security set-keychain-settings -t 3600 -u "$KEYCHAIN_NAME"
        security list-keychains -s "$KEYCHAIN_NAME" login.keychain

        # Import Apple WWDR G3 intermediate certificate to establish trust chain
        echo "Importing Apple WWDR G3 certificate..."
        WWDR_TEMP_DIR=$(mktemp -d)
        curl -sS -o "$WWDR_TEMP_DIR/AppleWWDRCAG3.cer" https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer
        security import "$WWDR_TEMP_DIR/AppleWWDRCAG3.cer" -k "$KEYCHAIN_NAME" -T /usr/bin/codesign
        rm -rf "$WWDR_TEMP_DIR"
        echo "Apple WWDR G3 certificate imported"

        # Import user's certificate with private key
        security import "$IOS_CERT_PATH" -k "$KEYCHAIN_NAME" -P "$IOS_CERT_PASSWORD" -T /usr/bin/codesign
        security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"

        # Install provisioning profile
        PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
        mkdir -p "$PROFILE_DIR"

        # Extract UUID from provisioning profile and copy with UUID as filename
        PROFILE_UUID=$(security cms -D -i "$IOS_PROVISIONING_PROFILE" 2>/dev/null | grep -A1 "<key>UUID</key>" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

        # Remove existing profile if it exists (may have read-only permissions)
        rm -f "$PROFILE_DIR/$PROFILE_UUID.mobileprovision"

        cp "$IOS_PROVISIONING_PROFILE" "$PROFILE_DIR/$PROFILE_UUID.mobileprovision"

        echo "Installed provisioning profile: $PROFILE_UUID"

        # Get signing identity (support both old "iPhone Distribution" and new "Apple Distribution")
        echo "Searching for signing identity in keychain..."
        security find-identity -v -p codesigning "$KEYCHAIN_NAME"

        SIGNING_IDENTITY=$(security find-identity -v -p codesigning "$KEYCHAIN_NAME" | grep -E "iPhone Distribution|Apple Distribution" | head -1 | awk '{print $2}')

        if [[ -z "$SIGNING_IDENTITY" ]]; then
            echo "ERROR: No Distribution certificate found in keychain!"
            echo "Available identities:"
            security find-identity -v -p codesigning "$KEYCHAIN_NAME"
            exit 1
        fi

        echo "Signing with identity: $SIGNING_IDENTITY"

        # Sign the app
        codesign --force --sign "$SIGNING_IDENTITY" --timestamp=none "$BIN_DIR/Status-tablet.app"

        # Verify signature
        codesign --verify --verbose "$BIN_DIR/Status-tablet.app"

        echo "iOS app signed successfully"

        # Create IPA file
        echo "Creating IPA file..."
        IPA_DIR=$(mktemp -d)
        mkdir -p "$IPA_DIR/Payload"
        cp -R "$BIN_DIR/Status-tablet.app" "$IPA_DIR/Payload/"

        # Create IPA (which is just a zip with .ipa extension)
        cd "$IPA_DIR"
        zip -r "$BIN_DIR/Status-tablet.ipa" Payload
        cd -

        rm -rf "$IPA_DIR"
        echo "IPA created at $BIN_DIR/Status-tablet.ipa"
    fi

    echo "Build succeeded"
fi
