#!/usr/bin/env bash
set -eof pipefail

[[ $(uname) != 'Darwin' ]] && { echo 'This only works on macOS.' >&2; exit 1; }
[[ $# -ne 1 ]] && { echo 'notarize-macos-pkg.sh <bundle_to_notarize>' >&2; exit 1; }

# Credential necessary for the upload.
[[ -z "${MACOS_NOTARIZE_TEAM_ID}" ]] && { echo -e "Missing env variable: MACOS_NOTARIZE_TEAM_ID" 1>&2; exit 1; }
[[ -z "${MACOS_NOTARIZE_USERNAME}" ]] && { echo -e "Missing env variable: MACOS_NOTARIZE_USERNAME" 1>&2; exit 1; }
[[ -z "${MACOS_NOTARIZE_PASSWORD}" ]] && { echo -e "Missing env variable: MACOS_NOTARIZE_PASSWORD" 1>&2; exit 1; }

# Path to MacOS bundle created by XCode.
BUNDLE_PATH="${1}"
# Notarization request check timeout.
CHECK_TIMEOUT="${CHECK_TIMEOUT:-10m}"
# Xcode notarization log file paths
NOTARIZATION_ERR_LOG="${NOTARIZATION_ERR_LOG:-${PWD}/notarization.out.log}"
NOTARIZATION_OUT_LOG="${NOTARIZATION_OUT_LOG:-${PWD}/notarization.err.log}"

function show_notarization_logs() {
    echo "FAILURE!"
    echo "STDERR:"
    cat "${NOTARIZATION_ERR_LOG}"
    echo "STDOUT:"
    cat "${NOTARIZATION_OUT_LOG}"
}
trap show_notarization_logs ERR

function xcrun_notarytool() {
    # STDERR goes to /dev/null so we can capture just the JSON.
    xcrun notarytool "${@}" \
        --team-id "${MACOS_NOTARIZE_TEAM_ID}" \
        --apple-id "${MACOS_NOTARIZE_USERNAME}" \
        --password "${MACOS_NOTARIZE_PASSWORD}" \
        --output-format "json" \
         > >(tee -a "${NOTARIZATION_OUT_LOG}") \
        2> >(tee -a "${NOTARIZATION_ERR_LOG}" >/dev/null)
}

# Submit app for notarization. Should take 5-10 minutes.
echo -e "\n### Creating Notarization Request..."
OUT=$(xcrun_notarytool submit --wait --timeout "${CHECK_TIMEOUT}" "${BUNDLE_PATH}")
# Necessary to track notarization request progress.
REQUEST_UUID=$(echo "${OUT}" | jq -r '.id')

if [[ -z "${REQUEST_UUID}" ]] || [[ "${REQUEST_UUID}" == "null" ]]; then
    echo "\n!!! FAILURE: No notarization request UUID found." >&1
    echo "Full output:"
    echo "${OUT}"
    exit 1
fi
echo -e "\n### Request ID: ${REQUEST_UUID}"

# Check notarization ticket status.
echo -e "\n### Checking Notarization Status..."
if $(echo "${OUT}" | jq -er '.status == "Accepted"'); then
    echo -e "\n### Successful Notarization"
else
    echo -e "\n!!! Notariztion Error"
    echo "${OUT}" >&2
    exit 1
fi

# Optional but preferrable to attach the ticket to the bundle.
echo -e "\n### Stapling Notarization Ticket..."
xcrun stapler staple "${BUNDLE_PATH}"

echo -e "\n### Validating Signature and Notarization..."
spctl --verbose=2 \
    --assess --type open \
    --context context:primary-signature \
    "${BUNDLE_PATH}"

exit $?
