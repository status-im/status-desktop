#!/bin/bash
# Flatpak wrapper script for Status Desktop

# Start pcscd daemon for smartcard support
PCSCD_RUN_DIR="/tmp/pcscd/run"
mkdir -p "${PCSCD_RUN_DIR}"
if [ -x /app/bin/pcscd ]; then
  /app/bin/pcscd -f &
fi

# Execute the actual application
exec /app/bin/nim_status_client "$@"
