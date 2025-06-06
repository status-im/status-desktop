
# Status Mobile Build System

This repository contains the build system for Status Mobile, supporting both iOS and Android platforms with Qt6 compatibility.
Cross-compilation is currently supported on MacOs and Linux. Windows is not supported. The dev setup runs well on WSL with Windows emulator.

## Table of Contents
- [Quick Start Guide (Container Builds) - Android](#quick-start-guide-container-builds)
- [Developer Setup Guide](#developer-setup-guide)
- [Build System Documentation](#build-system-documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Quick Start Guide (Container Builds)

This section is for users who want to get up and running quickly with minimal technical setup.

### Prerequisites
- Docker
- [act](https://github.com/nektos/act) (GitHub Actions local runner)
- ADB (Android Debug Bridge)
- Android Emulator

### Quick setup - android

1. **Install dependencies:**

```bash
# macOS
brew install docker --cask
# Start docker
open -a Docker
brew install act android-platform-tools android-commandlinetools
```

```bash
# Ubuntu
sudo apt-get update
sudo apt install android-sdk-common
sdkmanager --install "build-tools;35.0.1" "emulator" "platform-tools" "platforms;android-35" "ndk;27.2.12479018" 'system-images;android-35;google_apis;arm64-v8a'
# Installing act in /bin
(cd/;curlhttps://raw.githubusercontent.com/nektos/act/master/install.sh | sudobash)
```

2. **Verify installation:**
```bash
adb --version
emulator --version
avdmanager --version
sdkmanager --version
```

2. **Running the app**
```bash
# Linux and MacOS
make -f mobile/ContainerBuilds.mk run
```

### What Happens Behind the Scenes
- The build process uses GitHub Actions containers to ensure consistent builds
- All required tools and dependencies are provided by the container
- The built APK is copied from the container to the local `bin` directory

## Developer Setup Guide

This section is for developers who want full control over the build environment.ß

### iOS Development Setup

### Prerequisites

- Python 3.x
- Qt 6.9.0
- Xcode
- iPad Pro simulator

#### Setup Steps

1. **Install Qt for iOS (skip if you have it already):**
```bash
pip3 install -U pip
pip3 install aqtinstall

# Install Qt 5.15.2 (or6.9.0forQt6)
aqt install-qt mac ios 6.9.0 -O $HOME/qt -m all --autodesktop

# If the above fails on arm64, try:
arch -x86_64 aqt install-qt mac ios 6.9.0 -O $HOME/qt -m all --autodesktop
export PATH=$HOME/qt/6.9.0/ios/bin:$HOME/qt/6.9.0/macos/libexec:$HOME/qt/6.9.0/macos/bin:${PATH}
export QTDIR=$HOME/qt/6.9.0/ios
```

2. **Build and run:**
```bash
make mobile-run
```

### Android Development Setup

#### Prerequisites - can be installed using the Android Studio
- JDK 17
- Android SDK
- Android NDK 27.2.12479018
- Platform android-35
- Android emulator (optional)
- Android command-line tools

#### Setup Steps

1. **Install Qt for Android (skip if you have it already):**


Note: It's best to install the qt architecture matching the system architecture

```bash
# For Qt6 (includesdesktoptools)
# arm host
aqt install-qt mac android 6.9.0 android_arm64_v8a -O $HOME/qt -m all --autodesktop
# x64 host
aqt install-qt mac android 6.9.0 android_x86_64 -O $HOME/qt -m all --autodesktop
# optional
aqt install-qt mac android 6.9.0 android_x86 -O $HOME/qt -m all
aqt install-qt mac android 6.9.0 android_armv7 -O $HOME/qt -m all
```
2. **Set environment variables:**
```bash
# Set Java home
export JAVA_HOME=/path/to/jdk

# Set Android SDK and NDK paths
export ANDROID_SDK_ROOT=/path/to/android-sdk
export ANDROID_NDK_ROOT=/path/to/android-ndk/27.2.12479018

# Add Android tools to PATH
export PATH="$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"


# Add Qt to PATH. Qt6 needs both ios bin and host libexec and host bin (in this order!)
# exportPATH=[**yourQtPreferredFolder**]/6.9.0/[**yourPreferredAndroidTarget**]/bin:[**yourQtPreferredFolder**]/[**yourQtPreferredFolder**]/6.9.0/[**yourQtHostTarget**]/libexec:[**yourQtPreferredFolder**]/[**yourQtPreferredFolder**]/6.9.0/[**yourQtHostTarget**]/bin:${PATH}

```

3. **Validate the environment**
```
qmake --version # prints qmake for android
java --version # 17.0.14
emulator --version # execution works
echo $ANDROID_NDK_ROOT # points to 27.2.12479018
ls -l $ANDROID_SDK_ROOT/platforms/android-35 # android-35 in installed
avdmanager --version
sdkmanager --version
adb --version
```

4. **Build and run:**
```bash
make mobile-run
```

## Build System Documentation

### Environment Variables

The build system uses several environment variables to control the build process:

#### Build Control Variables
- `USE_SYSTEM_NIM=1`: Use system-installed Nim instead of building from source. Make sure `nim` and `nimble` are available

#### Platform Configuration
- `OS`: Target platform (`ios` or `android`) - qmake driven
- `ARCH`: Target architecture - defaults to host arch for android and `x86_64` for ios simulator
	- iOS: `arm64` (device) or `x86_64` (simulator)
	- Android: `arm64` (arm64-v8a), `arm` (armeabi-v7a), `x86_64`, or `x86`
- `PATH`: Should contain the path to Android or iOS Qt installation `bin` folder

#### Android-specific Variables
- `ANDROID_API`: Android API level (default: 28)
- `ANDROID_NDK_ROOT`: Path to Android NDK
- `ANDROID_SDK_ROOT`: Path to Android SDK
- `JAVA_HOME`: Path to JDK installation

#### iOS-specific Variables
- `IPHONE_SDK`: iOS SDK to use (`iphoneos` or `iphonesimulator`)
- `IOS_TARGET`: Minimum iOS version (16 for Qt6)

### Qt Version Compatibility

#### Qt6
- iOS minimum deployment target: iOS 16
- iOS simulator: iPad Pro
- Android target: Android 35
- Android NDK: 27.2.12479018
- Android API: 28
- JDK: 17

### Directory Structure
- `mobile/bin`: Final build outputs
- `mobile/lib`: Compiled libraries
- `mobile/build`: Intermediate build files
- `mobile/scripts`: Build scripts and utilities

### Key Components
- Status Go
- StatusQ
- DOtherSide
- OpenSSL
- QRCodeGen
- PCRE
- Nim Status Client

### Build Targets
- `make mobile-build`: Build all components
- `make mobile-clean`: Clean all build artifacts
- `make mobile-run`: Build and run the application

## Troubleshooting

### iOS Common Issues

1. **CMake Qt5 Error**
```
CMake Error at CMakeLists.txt:36 (find_package):
By not providing "FindQt5.cmake" in CMAKE_MODULE_PATH this project has
asked CMake to find a package configuration file provided by "Qt5", but
CMake did not find one.
```
**Fix**: Ensure `QTDIR` environment variable points to the Qt installation folder.

2. **Python Interpreter Error**
```
ios/mkspecs/features/uikit/devices.py: /usr/bin/python: bad interpreter: No such file or directory
```
**Fix**: Update the Python path in `ios/mkspecs/features/uikit/devices.py`.

3. **Missing distutils**
```
ModuleNotFoundError: No module named 'distutils'
```
**Fix**: `pip install setuptools`

4. **Invalid CFBundleVersion**
```
Simulator device failed to install the application.
The application's Info.plist does not contain a valid CFBundleVersion.
```
**Fix**: Remove `bin/Status-tablet.app` and run `make run`

5. **FBSOpenApplicationServiceErrorDomain**
```
Underlying error (domain=FBSOpenApplicationServiceErrorDomain, code=4):
```
**Fix**: In the simulator app, choose `Device -> Erase all content and settings`

### Android Common Issues

1.**PNG Rendering on macOS Emulator**
**Issue**: PNG files won't render on macOS emulator.
**Fix**: Add `setenv("QT_QUICK_BACKEND", "software", 1);` in main.cpp

2.**Gradle Crashes**
**Issue**: Gradle crashes during build.
**Fix**: Ensure sufficient RAM is available. A system restart may be needed.

3.**StatusQ Compilation Crashes**
**Issue**: Compiler crashes while compiling StatusQ.
**Fix**: Ensure at least 10GB of free RAM is available.

## Contributing

When contributing to the build system:
1. Test changes on both iOS and Android platforms
2. Qt6 compatibility is mandatory. Qt5 is nice to have for now
3. Update this README if necessary
4. Follow the existing build system patterns
