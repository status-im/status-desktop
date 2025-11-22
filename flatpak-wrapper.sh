#!/bin/bash
# Flatpak wrapper script for Status Desktop
# Sets up environment similar to AppRun for AppImage

# Set up GStreamer plugin paths
export GST_PLUGIN_SCANNER="/app/lib/gstreamer-1.0/gst-plugin-scanner"
export GST_PLUGIN_PATH="/app/lib/gstreamer-1.0"
export GST_PLUGIN_PATH_1_0="/app/lib/gstreamer-1.0"
export GST_PLUGIN_SYSTEM_PATH="/app/lib/gstreamer-1.0"
export GST_PLUGIN_SYSTEM_PATH_1_0="/app/lib/gstreamer-1.0"

# Set Qt WebEngine resources path
export QTWEBENGINE_RESOURCES_PATH="/app/libexec"

# Set up pcsc-lite environment
export PCSC_DRIVERS_DIR="/app/lib/pcsc/drivers"
export PCSCLITE_CONFIG_DIR="/app/etc/reader.conf.d"

# Start pcscd daemon
PCSCD_RUN_DIR="/tmp/pcscd/run"
rm -rf "${PCSCD_RUN_DIR}"
mkdir -p "${PCSCD_RUN_DIR}"

# Start pcscd in the background
if [ -x /app/bin/pcscd ]; then
  /app/bin/pcscd -f &
fi

# Handle locale
DEFAULT_LANG=en_US.UTF-8
if [[ "$LANG" == "C.UTF-8" ]]; then
  export LANG=$DEFAULT_LANG
fi

# Execute the actual application
exec /app/bin/nim_status_client "$@"
