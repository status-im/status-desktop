#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <aab-file-path>"
  exit 1
fi

AAB_FILE="$1"

function required_var() {
  if [[ -z "${!1}" ]]; then
    echo -e "ERROR: No required env variable: ${1}" 1>&2
    exit 1
  fi
}

required_var KEYSTORE_PATH
required_var KEYSTORE_PASSWORD
required_var KEY_ALIAS
required_var KEY_PASSWORD

if [[ ! -f "$AAB_FILE" ]]; then
  echo "ERROR: AAB file not found at $AAB_FILE"
  exit 1
fi

if [[ ! -f "$KEYSTORE_PATH" ]]; then
  echo "ERROR: Keystore file not found at $KEYSTORE_PATH"
  exit 1
fi

echo "Signing AAB with jarsigner..."
jarsigner -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore "$KEYSTORE_PATH" \
  -storepass "$KEYSTORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  "$AAB_FILE" "$KEY_ALIAS"

if [[ $? -ne 0 ]]; then
  echo "Error: AAB signing failed"
  exit 1
fi

echo "Verifying AAB signature..."
VERIFY_OUTPUT=$(jarsigner -verify "$AAB_FILE" 2>&1)
if echo "$VERIFY_OUTPUT" | grep -q "jar verified"; then
  echo "AAB signature verification: PASSED"
else
  echo "Error: AAB signature verification failed"
  echo "Verify output: $VERIFY_OUTPUT"
  exit 1
fi

echo "AAB signed successfully: $AAB_FILE"
