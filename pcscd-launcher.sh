#!/bin/bash
# Launcher for pcscd daemon in Flatpak environment

PCSCD_RUN_DIR="/tmp/pcscd/run"
rm -rf "${PCSCD_RUN_DIR}"
mkdir -p "${PCSCD_RUN_DIR}"

export PCSC_DRIVERS_DIR="/app/lib/pcsc/drivers"
export PCSCLITE_CONFIG_DIR="/app/etc/reader.conf.d"

exec /app/bin/pcscd -f "$@"
