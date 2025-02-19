#!/bin/sh
CWD=$(realpath `dirname $0`)
APP=${APP:="$CWD/../bin/$OS/IOS-build.apk"}
ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:=""}
EMULATOR=${EMULATOR:="$ANDROID_SDK_ROOT/emulator/emulator"}
ADB=${ADB:="$ANDROID_SDK_ROOT/platform-tools/adb"}

if [ "$ANDROID_SDK_ROOT" = "" ]; then
    echo "ANDROID_SDK_ROOT is not set. Please set ANDROID_SDK_ROOT to the path of your Android SDK."
    exit 1
fi

# print all available devices and emulators and let the user select one
echo "Running devices:"
device_list=$($ADB devices | awk 'NR>1 && /^[a-zA-Z0-9\-]+\tdevice$/ {print NR-1 ": " $1}')
echo "$device_list"

device_count=$(echo "$device_list" | wc -l)

echo "Emulators:"
emulator_list=$($EMULATOR -list-avds | awk -v device_count="$device_count" '{print NR+device_count ": " $1}')
echo "$emulator_list"

echo "Select a running device or emulator to use (enter the number):"
read selection

if [ "$selection" -le "$device_count" ]; then
    device_serial=$(echo "$device_list" | awk -v sel="$selection" 'NR==sel {print $2}')
    export ANDROID_SERIAL=$device_serial
    echo "Selected device: $device_serial"
else
    emulator_index=$(($selection - $device_count))
    avd_name=$(echo "$emulator_list" | awk -v sel="$emulator_index" 'NR==sel {print $2}')
    if [ -n "$avd_name" ]; then
        echo "Starting emulator: $avd_name"
        # Find an available port
        port=5554
        while netstat -an | grep -q ":$port "; do
            port=$((port + 2))
        done
        echo "Using port $port for emulator"
        $EMULATOR -avd "$avd_name" -port $port >/dev/null 2>&1 &
        emulator_pid=$!
        sleep 5
        # Check if the emulator started successfully
        if ! ps -p $emulator_pid > /dev/null; then
            echo "Failed to start emulator: $avd_name"
            exit 1
        fi
        export ANDROID_SERIAL=emulator-$port
        echo "Emulator started. Waiting to boot up."
        $ADB wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi
fi

echo "Installing app"
$ADB install -r $APP

echo "App installed. Starting app"
$ADB shell am start -a android.intent.action.MAIN -n org.qtproject.example.IOS_build/org.qtproject.qt5.android.bindings.QtActivity
$ADB logcat
