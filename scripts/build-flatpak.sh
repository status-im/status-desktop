#!/usr/bin/env bash

# Build script for Status Desktop Flatpak
# This script is used in CI to build the Flatpak package

set -eo pipefail

GIT_ROOT=$(cd "${BASH_SOURCE%/*}" && git rev-parse --show-toplevel)

# Configuration
FLATPAK_MANIFEST="${FLATPAK_MANIFEST:-app.status.desktop.yml}"
FLATPAK_BUILD_DIR="${FLATPAK_BUILD_DIR:-tmp/flatpak-build}"
FLATPAK_REPO_DIR="${FLATPAK_REPO_DIR:-tmp/flatpak-repo}"
OUTPUT_DIR="${OUTPUT_DIR:-pkg}"
BUNDLE_NAME="${BUNDLE_NAME:-app.status.desktop.flatpak}"

echo "Building Status Desktop Flatpak"
echo "Manifest: ${FLATPAK_MANIFEST}"
echo "Build dir: ${FLATPAK_BUILD_DIR}"
echo "Repo dir: ${FLATPAK_REPO_DIR}"
echo "Output: ${OUTPUT_DIR}/${BUNDLE_NAME}"

# Clean previous builds
echo "Cleaning previous builds"
rm -rf "${FLATPAK_BUILD_DIR}" "${FLATPAK_REPO_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Check if flatpak-builder is available
if ! command -v flatpak-builder &> /dev/null; then
    echo "Error: flatpak-builder not found"
    echo "Please install flatpak-builder:"
    echo "  Ubuntu/Debian: sudo apt install flatpak-builder"
    echo "  Fedora: sudo dnf install flatpak-builder"
    echo "  Arch: sudo pacman -S flatpak-builder"
    exit 1
fi

# Check if required runtimes are installed
echo "Checking Flatpak runtimes"
if ! flatpak info org.kde.Platform//6.8 &> /dev/null; then
    echo "Warning: org.kde.Platform//6.8 not found, installing..."
    flatpak install -y flathub org.kde.Platform//6.8 || {
        echo "Failed to install org.kde.Platform//6.8"
        exit 1
    }
fi

if ! flatpak info org.kde.Sdk//6.8 &> /dev/null; then
    echo "Warning: org.kde.Sdk//6.8 not found, installing..."
    flatpak install -y flathub org.kde.Sdk//6.8 || {
        echo "Failed to install org.kde.Sdk//6.8"
        exit 1
    }
fi

# Build Flatpak
echo "Building Flatpak with flatpak-builder"
flatpak-builder \
    --force-clean \
    --disable-rofiles-fuse \
    --repo="${FLATPAK_REPO_DIR}" \
    --ccache \
    --jobs=$(nproc) \
    "${FLATPAK_BUILD_DIR}" \
    "${FLATPAK_MANIFEST}"

# Create single-file bundle
echo "Creating Flatpak bundle"
flatpak build-bundle \
    "${FLATPAK_REPO_DIR}" \
    "${OUTPUT_DIR}/${BUNDLE_NAME}" \
    app.status.desktop

# Show bundle info
echo "Flatpak bundle created successfully"
ls -lh "${OUTPUT_DIR}/${BUNDLE_NAME}"

# Sign if GPG key is available
if [ -n "${LINUX_GPG_PRIVATE_KEY_FILE}" ]; then
    echo "Signing Flatpak bundle"
    "${GIT_ROOT}/scripts/sign-linux-file.sh" "${OUTPUT_DIR}/${BUNDLE_NAME}"
fi

echo "Build complete!"
echo ""
echo "To install locally:"
echo "  flatpak install --user ${OUTPUT_DIR}/${BUNDLE_NAME}"
echo ""
echo "To run:"
echo "  flatpak run app.status.desktop"
