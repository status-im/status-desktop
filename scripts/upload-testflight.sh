#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <ipa-file-path>"
  exit 1
fi

IPA_PATH="$1"

if [[ ! -f "$IPA_PATH" ]]; then
  echo "Error: IPA file not found at $IPA_PATH"
  exit 1
fi

if [[ -z "${ASC_KEY_ID:-}" || -z "${ASC_ISSUER_ID:-}" || -z "${ASC_KEY_FILE:-}" ]]; then
  echo "Error: Missing required environment variables"
  echo "Required: ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_FILE"
  exit 1
fi

if [[ ! -f "$ASC_KEY_FILE" ]]; then
  echo "Error: ASC_KEY_FILE not found at $ASC_KEY_FILE"
  exit 1
fi

TEMP_KEY_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_KEY_DIR'" EXIT

cp "$ASC_KEY_FILE" "$TEMP_KEY_DIR/AuthKey_${ASC_KEY_ID}.p8"

export API_PRIVATE_KEYS_DIR="$TEMP_KEY_DIR"

xcrun altool --upload-app \
  --type ios \
  --file "$IPA_PATH" \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID" \
  --verbose

echo "TestFlight upload completed successfully"
