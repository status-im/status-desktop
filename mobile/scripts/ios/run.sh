#!/bin/sh
set -ef pipefail

CWD=$(realpath `dirname $0`)
APPID=${APPID:=com.statusim.Status}
APP=${APP:="$CWD/../../bin/Applications/IOS-build.app"}
SIMULATOR_INFO=$(xcrun simctl list devices "iPad Pro" | grep -m 1 "iPad Pro")
SIMULATOR_DEVICE_ID=$(echo $SIMULATOR_INFO | grep -E -o -i "([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})")
SIMULATOR_DEVICE_STATE=$(echo $SIMULATOR_INFO | grep -E -o -i "\((Booted|Shutdown|Shutting Down|Creating|Deleting)\)" | tr -d '()')

echo "Booting simulator with device id: $SIMULATOR_DEVICE_ID and state: $SIMULATOR_DEVICE_STATE"

if [ "$SIMULATOR_DEVICE_STATE" != "Booted" ]; then
    xcrun simctl boot $SIMULATOR_DEVICE_ID
fi


echo "Installing app $APP on simulator $SIMULATOR_DEVICE_ID"
open -a Simulator --args -CurrentDeviceUDID $SIMULATOR_DEVICE_ID
xcrun simctl install $SIMULATOR_DEVICE_ID $APP
xcrun simctl launch  --console $SIMULATOR_DEVICE_ID com.yourcompany.IOS-build