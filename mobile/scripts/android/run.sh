#!/bin/sh

CWD=$(realpath `dirname $0`)
APP=${APP:="$CWD/../bin/$OS/Status-tablet.apk"}
ARCH=${ARCH:="arm64-v8a"}
ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:=""}
EMULATOR=${EMULATOR:="$ANDROID_SDK_ROOT/emulator/emulator"}
ADB=${ADB:="$ANDROID_SDK_ROOT/platform-tools/adb"}
# Optional params:
ANDROID_SERIAL=${ANDROID_SERIAL:=""} # Serial number of the device to use to avoid interactive selection

# It's only used if no device is connected and no emulator is defined
# to create a new emulator
AVDMANAGER=${AVDMANAGER:="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/avdmanager"}
SDKMANAGER=${SDKMANAGER:="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"}


if [ "$ADB" = "" ]; then
    echo "ADB is not set. Please set ADB to the path of your Android SDK."
    exit 1
fi

if [ "$EMULATOR" = "" ]; then
    echo "EMULATOR is not set. Please set EMULATOR to the path of your Android SDK."
    exit 1
fi

create_emulator() {
    # Detect host architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
        ABI="arm64-v8a"
    else
        ABI="x86_64"
    fi

    API_LEVEL="30"
    PACKAGE_NAME="system-images;android-${API_LEVEL};google_apis;${ABI}"
    AVD_NAME="status-default-avd"

    $SDKMANAGER --install "$PACKAGE_NAME" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to install system image for API level $API_LEVEL and ABI $ABI."
        exit 1
    fi

    # Create AVD if not exists
    if ! $AVDMANAGER list avd | grep -q "$AVD_NAME"; then
    echo "no" | avdmanager create avd \
        --name "$AVD_NAME" \
        --package "$PACKAGE_NAME" \
        --device "Nexus 10"
    fi
}

select_device_or_emulator() {

    # if no device is connected and no emulator defined, create a new emulator
    if [ -z "$($ADB devices | grep -E 'device$')" ] && [ -z "$($EMULATOR -list-avds)" ]; then
        echo "No device connected. We're creating a new emulator for you."
        # Create a new emulator with the default AVD name
        create_emulator
    fi

    # print all available devices and emulators and let the user select one
    echo "Running devices:"
    device_list=$($ADB devices | awk 'NR>1 && /^[a-zA-Z0-9\-]/ {print NR-1 ": " $1}')
    echo "$device_list"

    device_count=$(echo "$device_list" | wc -l)

    echo "Emulators:"
    emulator_list=$($EMULATOR -list-avds | awk -v device_count="$device_count" '{print NR+device_count ": " $1}')
    echo "$emulator_list"

    echo "Select a running device or emulator to use (enter the number):"
    read selection

    if [ "$selection" -le "$device_count" ]; then
        device_serial=$(echo "$device_list" | awk -v sel="$selection" 'NR==sel {print $2}')
        ANDROID_SERIAL=$device_serial
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
            ANDROID_SERIAL=emulator-$port
            echo "Emulator started. Waiting to boot up."
            $ADB wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
        else
            echo "Invalid selection. Exiting."
            exit 1
        fi
    fi
}

# Run on the connected device or emulator
if [ -z "$ANDROID_SERIAL" ]; then
    select_device_or_emulator
fi

echo "Installing app"
$ADB -s $ANDROID_SERIAL uninstall im.status.tablet
$ADB -s $ANDROID_SERIAL install -r $APP
if [ $? -ne 0 ]; then
    echo "App installation failed."
    exit 1
else
    echo "App installed successfully."
fi

echo "App installed. Starting app"
if [ "$QT_MAJOR" = "6" ]; then
    # For Qt6, use the new package name
    DEFAULT_ACTIVITY_NAME="im.status.tablet/org.qtproject.qt.android.bindings.QtActivity"
else
    # For Qt5, use the old package name
    DEFAULT_ACTIVITY_NAME="im.status.tablet/org.qtproject.qt5.android.bindings.QtActivity"
fi
$ADB -s $ANDROID_SERIAL shell am start -a android.intent.action.MAIN -n $DEFAULT_ACTIVITY_NAME
# wait for the app to start and then start logcat
echo "Waiting for the app to start"
while true; do
    PID=$($ADB -s $ANDROID_SERIAL shell pidof im.status.tablet | tr -d '\r')
    if [ -n "$PID" ]; then
        echo "App started with PID: $PID"
        break
    fi
    sleep 1
done

echo "Starting logcat with PID filter for $PID"
$ADB -s $ANDROID_SERIAL logcat --pid $PID
