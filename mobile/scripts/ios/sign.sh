#!/usr/bin/env bash
set -euo pipefail

CWD=$(realpath "$(dirname "$0")")
BIN_DIR=${BIN_DIR:-"$CWD/../../bin/ios"}

if [[ ! -e "$BIN_DIR/Status.app/Info.plist" ]]; then
  echo "Error: Status.app not found at $BIN_DIR/Status.app"
  exit 1
fi

function required_var() {
  if [[ -z "${!1}" ]]; then
    echo -e "ERROR: No required env variable: ${1}" 1>&2
    exit 1
  fi
}

required_var IOS_CERT_PATH
required_var IOS_CERT_PASSWORD
required_var IOS_PROVISIONING_PROFILE

echo "Signing iOS app at $BIN_DIR/Status.app..."

KEYCHAIN_NAME="build-$$.keychain"
KEYCHAIN_PASSWORD=$(openssl rand -base64 16)

cleanup_keychain() {
  echo "Cleaning up keychain..."
  security default-keychain -s login.keychain 2>/dev/null || true
  security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true
}

trap cleanup_keychain EXIT

security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security set-keychain-settings -t 3600 -u "$KEYCHAIN_NAME"
security list-keychains -s "$KEYCHAIN_NAME" login.keychain
security default-keychain -s "$KEYCHAIN_NAME"

echo "Importing Apple WWDR G3 certificate..."
WWDR_TEMP_DIR=$(mktemp -d)
curl -sS -o "$WWDR_TEMP_DIR/AppleWWDRCAG3.cer" https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer
security import "$WWDR_TEMP_DIR/AppleWWDRCAG3.cer" -k "$KEYCHAIN_NAME" -T /usr/bin/codesign
rm -rf "$WWDR_TEMP_DIR"
echo "Apple WWDR G3 certificate imported"

security import "$IOS_CERT_PATH" -k "$KEYCHAIN_NAME" -P "$IOS_CERT_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"

PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$PROFILE_DIR"

PROFILE_UUID=$(security cms -D -i "$IOS_PROVISIONING_PROFILE" 2>/dev/null | grep -A1 "<key>UUID</key>" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

rm -f "$PROFILE_DIR/$PROFILE_UUID.mobileprovision"

cp "$IOS_PROVISIONING_PROFILE" "$PROFILE_DIR/$PROFILE_UUID.mobileprovision"

echo "Installed provisioning profile: $PROFILE_UUID"

echo "Embedding provisioning profile into app..."
cp "$IOS_PROVISIONING_PROFILE" "$BIN_DIR/Status.app/embedded.mobileprovision"

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

echo "Extracting entitlements from provisioning profile..."
ENTITLEMENTS_PLIST=$(mktemp -t entitlements).plist

security cms -D -i "$IOS_PROVISIONING_PROFILE" | \
  plutil -extract Entitlements xml1 - -o "$ENTITLEMENTS_PLIST"

echo "Entitlements extracted to: $ENTITLEMENTS_PLIST"
cat "$ENTITLEMENTS_PLIST"

echo "Signing embedded frameworks..."
if [ -d "$BIN_DIR/Status.app/Frameworks" ]; then
  find "$BIN_DIR/Status.app/Frameworks" -name "*.framework" -type d | while read -r framework; do
    echo "Signing framework: $(basename "$framework")"
    codesign --force --sign "$SIGNING_IDENTITY" --timestamp "$framework"
  done
fi

echo "Signing main app bundle..."
codesign --force --sign "$SIGNING_IDENTITY" --entitlements "$ENTITLEMENTS_PLIST" --timestamp "$BIN_DIR/Status.app"

rm -f "$ENTITLEMENTS_PLIST"

echo "Verifying signature..."
codesign --verify --verbose=4 "$BIN_DIR/Status.app"

echo "Signature details:"
codesign -d --entitlements :- "$BIN_DIR/Status.app"

echo "iOS app signed successfully"

echo "Creating IPA file..."
IPA_DIR=$(mktemp -d)
mkdir -p "$IPA_DIR/Payload"
cp -R "$BIN_DIR/Status.app" "$IPA_DIR/Payload/"

cd "$IPA_DIR"
zip -r "$BIN_DIR/Status.ipa" Payload
cd -

rm -rf "$IPA_DIR"
echo "IPA created at $BIN_DIR/Status.ipa"
