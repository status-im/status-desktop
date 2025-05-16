#!/usr/bin/env bash
set -eof pipefail

if [[ $# -ne 1 ]]; then
    echo "No path to search for EXE and DLL files provided!" >&2
    exit 1
fi

function must_get_env() {
    declare -n VAR_VALUE="$1"
    if [[ -z "${VAR_VALUE}" ]]; then
        echo -e "Missing env variable: ${!VAR_VALUE}" 1>&2
        exit 1
    fi
}

# The timestamp server is always required.
must_get_env WINDOWS_CODESIGN_TIMESTAMP_URL

# Signing Tool usually comes with the Windows Kits.
WINDOWS_KITS='/c/Program Files (x86)/Windows Kits'
SIGNTOOL=$(find "${WINDOWS_KITS}" -iname 'signtool.exe' | grep x64 | sort | head -n1)
if [[ -z "${SIGNTOOL}" ]]; then
    echo "No signtool.exe was found in '${WINDOWS_KITS}'!" >&2
    exit 1
fi

# Find the files to sign.
FOUND_FILES=$(find "${1}" -type f -iname '*.dll' -or -iname '*.exe')
declare -a FILES_TO_SIGN

for FILE in ${FOUND_FILES}; do
    # Some files like Qt libraries are already signed.
    if "${SIGNTOOL}" verify -pa ${FILE} &>/dev/null; then
        continue
    fi
    FILES_TO_SIGN+=("${FILE}")
done

if [[ "${RELEASE:-false}" == "true" ]]; then
    echo "Using DigiCert KeyLocker for release signing..."

    # Check for required release signing variables
    must_get_env WINDOWS_DIGICERT_CERT_FINGERPRINT
    must_get_env SM_API_KEY
    must_get_env SM_CLIENT_CERT_PASSWORD
    must_get_env SM_CLIENT_CERT_FILE

    export SM_HOST='https://clientauth.one.digicert.com'

    # Sign with DigiCert KeyLocker
    "${SIGNTOOL}" sign -v -debug -td SHA256 -fd SHA256 \
        -sha1 "${WINDOWS_DIGICERT_CERT_FINGERPRINT}" \
        -tr "${WINDOWS_CODESIGN_TIMESTAMP_URL}" \
        "${FILES_TO_SIGN[@]}"
else
    echo "Using development certificate for signing..."

    # Check for required development signing variables
    must_get_env WINDOWS_CODESIGN_PASSWORD
    must_get_env WINDOWS_CODESIGN_PFX_PATH

    # Sign with development self-signed certificate
    "${SIGNTOOL}" sign -v -debug -td SHA256 -fd SHA256 \
        -p "${WINDOWS_CODESIGN_PASSWORD}" \
        -f "${WINDOWS_CODESIGN_PFX_PATH}" \
        -tr "${WINDOWS_CODESIGN_TIMESTAMP_URL}" \
        "${FILES_TO_SIGN[@]}"
fi

echo "Signed successfully!"