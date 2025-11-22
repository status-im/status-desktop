#!/usr/bin/env bash

# Build script for Status Desktop Flatpak
# This script is used in CI to build the Flatpak package

set -eo pipefail

GIT_ROOT=$(cd "${BASH_SOURCE%/*}" && git rev-parse --show-toplevel)

FLATPAK_MANIFEST="${FLATPAK_MANIFEST:-app.status.desktop.yml}"
FLATPAK_BUILD_DIR="${FLATPAK_BUILD_DIR:-tmp/flatpak-build}"
FLATPAK_REPO_DIR="${FLATPAK_REPO_DIR:-tmp/flatpak-repo}"

if [ -n "${STATUS_CLIENT_FLATPAK}" ]; then
  OUTPUT_PATH="${STATUS_CLIENT_FLATPAK}"
  OUTPUT_DIR="$(dirname "${OUTPUT_PATH}")"
else
  OUTPUT_DIR="${OUTPUT_DIR:-pkg}"
  OUTPUT_PATH="${OUTPUT_DIR}/status-desktop.flatpak"
fi

echo "Building Status Desktop Flatpak"
echo "Manifest: ${FLATPAK_MANIFEST}"
echo "Build dir: ${FLATPAK_BUILD_DIR}"
echo "Repo dir: ${FLATPAK_REPO_DIR}"
echo "Output: ${OUTPUT_PATH}"

echo "Cleaning previous builds"
rm -rf "${FLATPAK_BUILD_DIR}" "${FLATPAK_REPO_DIR}"
mkdir -p "${OUTPUT_DIR}"

if [ ! -f "bin/nim_status_client" ]; then
  echo "Building Status Desktop application"
  make nim_status_client
fi

# Build Flatpak
# We use --build-only and then manually finish/export to avoid appstream-compose
# running inside the sandbox (it's not available in the KDE SDK runtime)
echo "Building Flatpak with flatpak-builder"
flatpak-builder \
  --force-clean \
  --disable-rofiles-fuse \
  --disable-cache \
  --build-only \
  --jobs=$(nproc) \
  "${FLATPAK_BUILD_DIR}" \
  "${FLATPAK_MANIFEST}"

# Finish the build (apply permissions from manifest)
echo "Finishing Flatpak build"
flatpak build-finish \
  --command=nim_status_client_wrapped \
  --share=ipc \
  --socket=x11 \
  --socket=wayland \
  --share=network \
  --socket=pulseaudio \
  --device=dri \
  --device=all \
  --filesystem=xdg-download \
  --filesystem=xdg-documents \
  --filesystem=xdg-pictures \
  --filesystem=xdg-videos \
  --socket=session-bus \
  --socket=system-bus \
  --talk-name=org.freedesktop.Notifications \
  --filesystem=~/.status-im:create \
  "--env=XCURSOR_PATH=/run/host/user-share/icons:/run/host/share/icons" \
  "--env=QT_QPA_PLATFORM=xcb" \
  "${FLATPAK_BUILD_DIR}"

echo "Exporting to Flatpak repository"
flatpak build-export "${FLATPAK_REPO_DIR}" "${FLATPAK_BUILD_DIR}"

echo "Creating Flatpak bundle"
flatpak build-bundle \
  "${FLATPAK_REPO_DIR}" \
  "${OUTPUT_PATH}" \
  app.status.desktop

echo "Flatpak bundle created successfully"
ls -lh "${OUTPUT_PATH}"

if [ -n "${LINUX_GPG_PRIVATE_KEY_FILE}" ]; then
  echo "Signing Flatpak bundle"
  "${GIT_ROOT}/scripts/sign-linux-file.sh" "${OUTPUT_PATH}"
fi

echo "Build complete!"
echo ""
echo "To install locally:"
echo "  flatpak install --user ${OUTPUT_PATH}"
echo ""
echo "To run:"
echo "  flatpak run app.status.desktop"
