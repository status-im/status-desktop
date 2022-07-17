#!/usr/bin/env bash

set -e

[[ $(uname) != 'Darwin' ]] && { echo 'This only works on macOS.' >&2; exit 1; }
[[ $# -lt 2 ]] && { echo 'sign-macos-bundle.sh <file_to_sign> <sign_identity>' >&2; exit 1; }

# First is the target file/directory to sign
TARGET="${1}"
# Second argument is the signing identity
CODESIGN_ID="${2}"
# Rest are extra command line flags for codesign
shift 2
CODESIGN_OPTS_EXTRA=("${@}")

[[ ! -e "${TARGET}" ]] && { echo 'Target file does not exist.' >&2; exit 1; }

function clean_up {
    STATUS=$?
    if [[ "${STATUS}" -eq 0 ]]; then
        echo -e "\n###### ERROR: See above for details."
    fi
    set +e

    echo -e "\n###### Cleaning up..."
    echo -e "\n### Locking keychain..."
    security lock-keychain "${MACOS_KEYCHAIN_FILE}"
    echo -e "\n### Restoring default keychain search list..."
    security list-keychains -s ${ORIG_KEYCHAIN_LIST}
    security list-keychains

    exit $STATUS
}

# Flags for codesign
CODESIGN_OPTS=(
    "--sign ${CODESIGN_ID}"
    "--options runtime"
    "--verbose=4"
    "--force"
)
# Add extra flags provided via command line
CODESIGN_OPTS+=(
    ${CODESIGN_OPTS_EXTRA[@]}
)

# Setting MACOS_KEYCHAIN_FILE nd MACOS_KEYCHAIN_PASS is not required because
# MACOS_CODESIGN_IDENT can be found in e.g. your login keychain.
# Those would normally be specified only in CI.
if [[ -n "${MACOS_KEYCHAIN_FILE}" ]]; then
    if [[ -z "${MACOS_KEYCHAIN_PASS}" ]]; then
        echo "Unable to unlock the keychain without MACOS_KEYCHAIN_PASS!" >&2
        exit 1
    fi
    echo -e "\n### Storing original keychain search list..."
    # We want to restore the normal keychains and ignore Jenkis created ones
    ORIG_KEYCHAIN_LIST=$(security list-keychains | grep -v -e "^/private" -e "secretFiles" | xargs)
    
    # The keychain file needs to be locked afterwards
    trap clean_up EXIT ERR

    echo -e "\n### Adding keychain to search list..."
    security list-keychains -s ${ORIG_KEYCHAIN_LIST} "${MACOS_KEYCHAIN_FILE}"
    security list-keychains
    echo -e "\n### Unlocking keychain..."
    security unlock-keychain -p "${MACOS_KEYCHAIN_PASS}" "${MACOS_KEYCHAIN_FILE}"

    # Add a flag to use the unlocked keychain
    CODESIGN_OPTS+=("--keychain ${MACOS_KEYCHAIN_FILE}")
fi

# If 'TARGET' is a directory, we assume it's an app
# bundle, otherwise we consider it to be a dmg.
if [[ -d "${TARGET}" ]]; then
    CODESIGN_OPTS+=("--deep")
fi

echo -e "\n### Signing target..."
codesign ${CODESIGN_OPTS[@]} "${TARGET}"

echo -e "\n### Verifying signature..."
codesign --verify --strict=all --deep --verbose=4 "${TARGET}"

echo -e "\n### Assessing Gatekeeper validation..."
if [[ -d "${TARGET}" ]]; then
    spctl --assess --type execute --verbose=2 "${TARGET}"
else
    echo "WARNING: The 'open' type security assesment is disabled due to lack of 'Notarization'"
    # Issue: https://github.com/status-im/status-mobile/pull/9172
    # Details: https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution
    #spctl --assess --type open --context context:primary-signature --verbose=2 "${OBJECT}"
fi

echo -e "\n###### DONE"
