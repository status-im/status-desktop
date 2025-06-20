#!/usr/bin/env bash
# iOS run helper – mirrors the behaviour of mobile/scripts/android/run.sh
# 1. Lists available iOS simulators and lets the user choose one.
# 2. If no simulator exists, a default iPad simulator is created automatically.
# 3. Boots the chosen simulator (if needed), installs the built app and launches it.

set -euo pipefail
set -o xtrace

CWD=$(realpath "$(dirname "$0")")
APPID=${APPID:-im.status.Status-tablet}            # Bundle identifier of the app
APP=${APP:-"$CWD/../../bin/Applications/Status-tablet.app"}  # Path to the .app bundle
SIMULATOR_UDID=${SIMULATOR_UDID:-""}               # Specify to skip interactive selection

# Create a default iPad simulator if none are found
create_default_simulator() {
  DEFAULT_NAME="status-default-sim"
  DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPad-Pro-11-inch-M4-16GB"

  echo "Creating default simulator: $DEFAULT_NAME ($DEVICE_TYPE)"
  xcrun simctl create "$DEFAULT_NAME" "$DEVICE_TYPE" || {
    echo "Failed to create the default simulator"; exit 1;
  }
}

# Present the list of available simulators and let the user pick one
select_simulator() {
  local device_lines
  device_lines=$(xcrun simctl list devices available | grep -E "^\s{4}.*\(" || true)

  if [[ -z "$device_lines" ]]; then
    echo "No simulators found. Creating a default one..."
    create_default_simulator
    device_lines=$(xcrun simctl list devices available | grep -E "^\s{4}.*\(")
  fi

  echo "Available simulators:"
  echo "$device_lines" | nl -w2 -s': '

  read -rp "Select a simulator to use (enter number): " selection

  local selected_line
  selected_line=$(echo "$device_lines" | sed -n "${selection}p")
  if [[ -z "$selected_line" ]]; then
    echo "Invalid selection. Exiting."; exit 1;
  fi

  SIMULATOR_UDID=$(echo "$selected_line" | grep -E -o "([0-9A-Fa-f-]{36})")
  SIMULATOR_NAME=$(echo "$selected_line" | sed -E 's/^\s+([^()]*)\s+\(.*/\1/' | xargs)
}

# If no UDID provided via env var, ask the user
if [[ -z "$SIMULATOR_UDID" ]]; then
  select_simulator
fi

# Get info/state for the chosen simulator
SIMULATOR_INFO=$(xcrun simctl list devices | grep "$SIMULATOR_UDID" | head -n 1 || true)
if [[ -z "$SIMULATOR_INFO" ]]; then
  echo "Simulator $SIMULATOR_UDID not found. Exiting."; exit 1;
fi
SIMULATOR_STATE=$(echo "$SIMULATOR_INFO" | grep -E -o "\((Booted|Shutdown|Shutting Down|Creating|Deleting)\)" | tr -d '()')

echo "Using simulator: ${SIMULATOR_NAME:-$SIMULATOR_UDID} – state: $SIMULATOR_STATE"

# Boot if necessary
if [[ "$SIMULATOR_STATE" != "Booted" ]]; then
  echo "Booting simulator $SIMULATOR_UDID..."
  xcrun simctl boot "$SIMULATOR_UDID"
fi

# Bring Simulator app to foreground with the chosen device
open -a Simulator --args -CurrentDeviceUDID "$SIMULATOR_UDID"

# Re-install the app
echo "Installing app $APP onto simulator $SIMULATOR_UDID"
xcrun simctl install "$SIMULATOR_UDID" "$APP"

# Launch the app (using --console-pty to avoid freeze issues)
echo "Launching $APPID"
xcrun simctl launch --console-pty "$SIMULATOR_UDID" "$APPID"