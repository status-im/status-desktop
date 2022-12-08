#!/usr/bin/env bash

set -e

[[ $(uname) != 'Darwin' ]] && { echo 'This only works on macOS.' >&2; exit 1; }
[[ $# -ne 1 ]] && { echo 'notarize-macos-pkg.sh <bundle_to_notarize>' >&2; exit 1; }

# Credential necessary for the upload.
[[ -z "${MACOS_NOTARIZE_TEAM_ID}" ]] && { echo -e "Missing env variable: MACOS_NOTARIZE_TEAM_ID" 1>&2; exit 1; }
[[ -z "${MACOS_NOTARIZE_USERNAME}" ]] && { echo -e "Missing env variable: MACOS_NOTARIZE_USERNAME" 1>&2; exit 1; }
[[ -z "${MACOS_NOTARIZE_PASSWORD}" ]] && { echo -e "Missing env variable: MACOS_NOTARIZE_PASSWORD" 1>&2; exit 1; }

# Path to MacOS bundle created by XCode.
BUNDLE_PATH="${1}"
# Notarization request check intervals/retries.
CHECK_INTERVAL_SEC="${CHECK_INTERVAL_SEC:-30}"
CHECK_RETRY_LIMIT="${CHECK_RETRY_LIMIT:-20}"
# Unique ID of MacOS application.
MACOS_BUNDLE_ID="${MACOS_BUNDLE_ID:-im.status.ethereum.desktop}"
# Log file path
NOTARIZATION_LOG="${NOTARIZATION_LOG:-${PWD}/notarization.log}"

function xcrun_altool() {
    xcrun altool "${@}" \
        --team-id "${MACOS_NOTARIZE_TEAM_ID}" \
        --username "${MACOS_NOTARIZE_USERNAME}" \
        --password "${MACOS_NOTARIZE_PASSWORD}" \
        --output-format "json" \
        2>&1 | tee -a "${NOTARIZATION_LOG}"
}

# Submit app for notarization. Should take 5-10 minutes.
echo -e "\n### Creating Notarization Request..."
OUT=$(xcrun_altool --notarize-app -f "${BUNDLE_PATH}" --primary-bundle-id "${MACOS_BUNDLE_ID}")
# Necessary to track notarization request progress.
REQUEST_UUID=$(echo "${OUT}" | jq -r '."notarization-upload".RequestUUID')

if [[ -z "${REQUEST_UUID}" ]] || [[ "${REQUEST_UUID}" == "null" ]]; then
    echo "\n!!! FAILURE: No notarization request UUID found." >&1
    echo "Full output:"
    echo "${OUT}"
    exit 1
fi
echo -e "\n### Request ID: ${REQUEST_UUID}"

# Check notarization ticket status periodically.
echo -e "\n### Checking Notarization Status..."
while sleep "${CHECK_INTERVAL_SEC}"; do
    OUT=$(xcrun_altool --notarization-info "${REQUEST_UUID}")

    # Once notarization is complete, run stapler and exit.
    if $(echo "${OUT}" | jq -er '."notarization-info".Status == "in progress"'); then
        ((CHECK_RETRY_LIMIT-=1))
        if [[ "${CHECK_RETRY_LIMIT}" -eq 0 ]]; then
            echo -e "\n!!! FAILURE: Notarization timed out."
            exit 1
        fi
        echo "In progress, sleeping ${CHECK_INTERVAL_SEC}s..."
    elif $(echo "${OUT}" | jq -er '."notarization-info".Status == "success"'); then
        echo -e "\n### Successful Notarization"
        break
    else
        echo -e "\n!!! Notariztion Error"
        echo "${OUT}" >&2
        exit 1
    fi
done

# Optional but preferrable to attach the ticket to the bundle.
echo -e "\n### Stapling Notarization Ticket..."
xcrun stapler staple "${BUNDLE_PATH}"
exit $?
