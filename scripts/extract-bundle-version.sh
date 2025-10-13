#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <ipa-file-path>" >&2
  exit 1
fi

IPA_PATH="$1"

if [[ ! -f "$IPA_PATH" ]]; then
  echo "Error: IPA file not found at $IPA_PATH" >&2
  exit 1
fi

unzip -p "$IPA_PATH" 'Payload/*.app/Info.plist' | \
  plutil -extract CFBundleVersion raw -o - -
