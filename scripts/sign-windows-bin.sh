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

# The signing client certificate, keypair alias, password, and timestamp server is required.
must_get_env WINDOWS_DIGICERT_KEYPAIR_ALIAS
must_get_env WINDOWS_DIGICERT_CLIENT_PASSWORD
must_get_env WINDOWS_DIGICERT_CLIENT_CERT
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

# Sign all the non-signed binaries. Add -debug if need be.
"${SIGNTOOL}" sign -csp "DigiCert Signing Manager KSP" -v -debug -fd SHA256 \
    -kc "${WINDOWS_DIGICERT_KEYPAIR_ALIAS}" \
    -p "${WINDOWS_DIGICERT_CLIENT_PASSWORD}" \
    -f "${WINDOWS_DIGICERT_CLIENT_CERT}" \
    -tr "${WINDOWS_CODESIGN_TIMESTAMP_URL}" \
    "${FILES_TO_SIGN[@]}"

echo "Signed successfully!"
