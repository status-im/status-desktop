# Status Tablet Build System

This repository contains the build system for Status Tablet, supporting both iOS and Android platforms with Qt5 and Qt6 compatibility.
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
    git clone <repository-url>
    cd <repository-name>
    git submodule update --init --recursive
   ```

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
   sudo apt install android-sdk-common google-android-emulator-installer docker.io
   # Installing act in /bin
   (cd /;curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash)
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
   make -f ContainerBuilds.mk run
   ```

### What Happens Behind the Scenes
- The build process uses GitHub Actions containers to ensure consistent builds
- All required tools and dependencies are provided by the container
- The built APK is copied from the container to the local `bin` directory

## Developer Setup Guide

This section is for developers who want full control over the build environment.ß

### Prerequisites
- Git
- Python 3.x
- Qt (5.15.2 or 6.8.3)
- Platform-specific requirements (see below)

### Common Setup

1. **Clone the repository and submodules:**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   git submodule update --init --recursive
   ```

2. **Install Qt using aqtinstall:**
   ```bash
   pip3 install -U pip
   pip3 install aqtinstall
   ```

### iOS Development Setup

#### Prerequisites
- Xcode
- iPad Pro simulator
- Qt 5.15.2 or 6.8.3 for iOS

#### Setup Steps

1. **Install Qt for iOS (skip if you have it already):**
   ```bash

   # Install Qt 5.15.2 (or 6.8.3 for Qt6)
   aqt install-qt mac ios 6.8.3 -O [**yourQtPreferredFolder**] -m all --autodesktop

   # If the above fails on arm64, try:
   arch -x86_64 aqt install-qt mac ios 6.8.3 -O [**yourQtPreferredFolder**] -m all --autodesktop
   ```

2. **Set environment variables:**
   
   ```bash
   # Add Qt to PATH. Qt6 needs both ios bin and host libexec
   # export PATH=[**yourQtPreferredFolder**]/6.8.3/ios/bin:[**yourQtPreferredFolder**]/[**yourQtPreferredFolder**]/6.8.3/[**yourQtHostTarget**]/libexec:${PATH}
   ```

3. **Build and run:**
   ```bash
   make run
   ```

### Android Development Setup

#### Prerequisites - can be installed using the Android Studio
- JDK 17 (11 for Qt5)
- Android SDK
- Android NDK (21.3.6528147 for Qt5, 26.1.10909125 for Qt6)
- Android emulator
- Android command-line tools

#### Setup Steps

1. **Install Qt for Android (skip if you have it already):**


   Note: It's best to install the qt architecture matching the system architecture

   ```bash
   # Install Qt 5.15.2
   aqt install-qt mac android 5.15.2 -O [**yourQtPreferredFolder**]

   # For Qt6 (includes desktop tools)
   # arm host
   aqt install-qt mac android 6.8.3 android_arm64_v8a -O [**yourQtPreferredFolder**] -m all --autodesktop
   # x64 host
   aqt install-qt mac android 6.8.3 android_x86_64 -O [**yourQtPreferredFolder**] -m all --autodesktop
   # optional
   aqt install-qt mac android 6.8.3 android_x86 -O [**yourQtPreferredFolder**] -m all
   aqt install-qt mac android 6.8.3 android_armv7 -O [**yourQtPreferredFolder**] -m all
   ```
2. **Set environment variables:**
   ```bash
   # Set Java home
   export JAVA_HOME=/path/to/jdk

   # Set Android SDK and NDK paths
   export ANDROID_HOME=/path/to/android-sdk
   export ANDROID_NDK_HOME=/path/to/android-ndk
   export SDK_PATH="$ANDROID_HOME"

   # Add Android tools to PATH
   export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"


   # Add Qt to PATH. Qt6 needs both ios bin and host libexec and host bin (in this order!)
   # export PATH=[**yourQtPreferredFolder**]/6.8.3/[**yourPreferredAndroidTarget**]/bin:[**yourQtPreferredFolder**]/[**yourQtPreferredFolder**]/6.8.3/[**yourQtHostTarget**]/libexec:[**yourQtPreferredFolder**]/[**yourQtPreferredFolder**]/6.8.3/[**yourQtHostTarget**]/bin:${PATH}

   ```
3. **Create Android Virtual Device (optional - one will be created by default):**
   ```bash
   # It's best to choose the host arch
   avdmanager create avd -n "Test_avd_x64" -k "system-images;android-Baklava;google_apis_playstore;x86_64" -d 70
   ```

4. **Build and run:**
   ```bash
   make run
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
- `ANDROID_NDK_HOME`: Path to Android NDK
- `ANDROID_HOME`: Path to Android SDK
- `SDK_PATH`: Path to Android SDK (used by some build scripts)
- `JAVA_HOME`: Path to JDK installation

#### iOS-specific Variables
- `IPHONE_SDK`: iOS SDK to use (`iphoneos` or `iphonesimulator`)
- `IOS_TARGET`: Minimum iOS version (12 for Qt5, 16 for Qt6)

### Qt Version Compatibility

#### Qt5 (Default)
- iOS minimum deployment target: iOS 12
- iOS simulator: iPad Pro
- Android target: Android 31
- Android NDK: 21.3.6528147
- Android API: 28
- JDK: 11

#### Qt6
- iOS minimum deployment target: iOS 16
- iOS simulator: iPad Pro
- Android target: Android 35
- Android NDK: 26.1.10909125
- Android API: 28
- JDK: 17

### Directory Structure
- `bin/`: Final build outputs
- `lib/`: Compiled libraries
- `build/`: Intermediate build files
- `scripts/`: Build scripts and utilities

### Key Components
- Status Go
- StatusQ
- DOtherSide
- OpenSSL
- QRCodeGen
- PCRE
- Nim Status Client

### Build Targets
- `make`: Build all components
- `make clean`: Clean all build artifacts
- `make run`: Build and run the application
- Platform-specific targets (e.g., `make iosdevice`)

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

1. **PNG Rendering on macOS Emulator**  
   **Issue**: PNG files won't render on macOS emulator.  
   **Fix**: Add `setenv("QT_QUICK_BACKEND", "software", 1);` in main.cpp

2. **Gradle Crashes**  
   **Issue**: Gradle crashes during build.  
   **Fix**: Ensure sufficient RAM is available. A system restart may be needed.

3. **StatusQ Compilation Crashes**  
   **Issue**: Compiler crashes while compiling StatusQ.  
   **Fix**: Ensure at least 10GB of free RAM is available.

## Contributing

When contributing to the build system:
1. Test changes on both iOS and Android platforms
2. Qt6 compatibility is mandatory. Qt5 is nice to have for now
3. Update this README if necessary
4. Follow the existing build system patterns
