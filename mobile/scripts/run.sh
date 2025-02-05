#!/bin/sh
CWD=$(realpath `dirname $0`)
APPID=${APPID:=com.statusim.Status}
APP=${APP:="$CWD/../bin/IOS-build.app"}
SIMULATOR_DEVICE_ID=${SIMULATOR_DEVICE_ID:=$(xcrun simctl list devices "iPad Pro" | grep -m 1 "iPad Pro" |grep -E -o -i "([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})")}

echo "Booting simulator with device id: $SIMULATOR_DEVICE_ID"

xcrun simctl boot $SIMULATOR_DEVICE_ID
open -a Simulator --args -CurrentDeviceUDID $SIMULATOR_DEVICE_ID
xcrun simctl install $SIMULATOR_DEVICE_ID $CWD/../bin/IOS-build.app
xcrun simctl launch  --console $SIMULATOR_DEVICE_ID com.yourcompany.IOS-build