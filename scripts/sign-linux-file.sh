#!/usr/bin/env bash
set -eof pipefail

# Checks -----------------------------------------------------------------------

if [[ $(uname) != 'Linux' ]]; then
    echo 'This only works on Linux.' >&2
    exit 1
fi
if [[ $# -lt 1 ]]; then
    echo 'sign-linux-tarball.sh <file_to_sign>' >&2
    exit 1
fi
if [[ -z "${LINUX_GPG_PRIVATE_KEY_FILE}" ]]; then
    echo "Unable to import GPG key file if LINUX_GPG_PRIVATE_KEY_FILE is not set!" >&2
    exit 1
fi
if [[ -z "${LINUX_GPG_PRIVATE_KEY_PASS}" ]]; then
    echo "Unable to import GPG key file if LINUX_GPG_PRIVATE_KEY_PASS is not set!" >&2
    exit 1
fi
if [[ ! -f "${LINUX_GPG_PRIVATE_KEY_FILE}" ]]; then
    echo "No such file exists: ${LINUX_GPG_PRIVATE_KEY_FILE}" >&2
    exit 1
fi

# Signing ----------------------------------------------------------------------

function clean_up {
    STATUS=$?
    if [[ "${STATUS}" -ne 0 ]]; then
        echo -e "\n###### ERROR: See above for details."
    fi
    set +e

    echo -e "\n### Removing Temporary Keyring..."
    rm -frv "${GNUPGHOME}"
    exit $STATUS
}

# First and only argument is the file to create signature for
TARGET="${1}"

# Use a temporary GPG home and for the keyring.
export GNUPGHOME=$(mktemp -d $HOME/.gnupg.tmp.XXXXXX)
# Remove the GPG home along with the keyring regardless of how script exits.
trap clean_up EXIT

# Fix for 'gpg: signing failed: Inappropriate ioctl for device' in Docker
echo 'allow-loopback-pinentry' > "${GNUPGHOME}/gpg-agent.conf"
echo 'pinentry-mode loopback' > "${GNUPGHOME}/gpg.conf"

# Import the GPG key file into the temporary keyring.
echo -e "\n### Importing GPG private key..."
gpg2 --batch --yes --passphrase-fd 0 \
    --import "${LINUX_GPG_PRIVATE_KEY_FILE}" \
    <<< "${LINUX_GPG_PRIVATE_KEY_PASS}"

# Trust all immported keys ultimately.
gpg2 --list-secret-keys --with-colons \
    | awk -F: '/fpr/{printf "%s:6:\n", $10}' \
    | gpg2 --import-ownertrust --batch

echo -e "\n### Signing target..."
gpg2 --batch --yes --passphrase-fd 0 --verbose \
    --armor --detach-sign "${TARGET}" \
    <<< "${LINUX_GPG_PRIVATE_KEY_PASS}"

echo -e "\n### Verifying signature..."
gpg2 --batch --verify "${TARGET}.asc" "${TARGET}"

echo -e "\n### DONE"
