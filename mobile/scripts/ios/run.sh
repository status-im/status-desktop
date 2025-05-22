#!/bin/sh
set -o xtrace
set -ef pipefail

CWD=$(realpath `dirname $0`)
APPID=${APPID:=com.statusim.Status}
APP=${APP:="$CWD/../../bin/Applications/Status-tablet.app"}
echo "APP: $APP"
SIMULATOR_INFO=$(xcrun simctl list devices "iPad Pro" | grep -m 1 "iPad Pro" || true)

echo "Simulator info: $SIMULATOR_INFO"
if [ -z "$SIMULATOR_INFO" ]; then
    echo "No matching simulator found. Creating a new one..."
    xcrun simctl create "iPad Pro" com.apple.CoreSimulator.SimDeviceType.iPad-Pro-11-inch-M4-16GB
    SIMULATOR_INFO=$(xcrun simctl list devices | grep -m 1 "iPad Pro")
    if [ -z "$SIMULATOR_INFO" ]; then
        echo "Failed to create or find the simulator. Exiting."
        exit 1
    fi
fi

SIMULATOR_DEVICE_ID=$(echo $SIMULATOR_INFO | grep -E -o -i "([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})")
SIMULATOR_DEVICE_STATE=$(echo $SIMULATOR_INFO | grep -E -o -i "\((Booted|Shutdown|Shutting Down|Creating|Deleting)\)" | tr -d '()')

echo "Booting simulator with device id: $SIMULATOR_DEVICE_ID and state: $SIMULATOR_DEVICE_STATE"

if [ "$SIMULATOR_DEVICE_STATE" != "Booted" ]; then
    xcrun simctl boot $SIMULATOR_DEVICE_ID
fi


echo "Installing app $APP on simulator $SIMULATOR_DEVICE_ID"
open -a Simulator --args -CurrentDeviceUDID $SIMULATOR_DEVICE_ID
xcrun simctl install $SIMULATOR_DEVICE_ID $APP
xcrun simctl launch  --console $SIMULATOR_DEVICE_ID im.status.Status-tablet