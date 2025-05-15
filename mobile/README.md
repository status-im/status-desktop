# Qt Version Compatibility

This project supports both Qt5 and Qt6. The build system automatically detects your Qt version and adjusts accordingly.

## Building with Qt5 (Default)
- iOS minimum deployment target: iOS 12
- IOS simulator: Ipad pro
- Android target: Android 31
- Android ndk: 21.3.6528147
- Android API: 28
- JDK: 11

## Building with Qt6
- iOS minimum deployment target: iOS 16
- IOS simulator: Ipad pro
- Android target: Android 35
- Android ndk: 26.1.10909125
- Android API: 28
- JDK: 17

# IOS

### Running the app

#### Prerequisites:
- Make sure status-desktop can be built
- Qt 5.15.2 for IOS or Qt 6.8.3 for IOS
- Python
- Clone submodules
```
  git submodule update --init --recursive
```
- Xcode
- Ipad pro simulator

#### Installing qt
```
  pip3 install -U pip
  pip3 install aqtinstall
  aqt install-qt mac ios 6.8.3 -O ${QT_INSTALL_DIR} --autodesktop
  ### OR if it fails for arm64
  arch -x86_64 aqt install-qt mac ios 6.8.3 -O ${QT_INSTALL_DIR}/5.15.2/ios --autodesktop

  export QTDIR=${QT_INSTALL_DIR}/5.15.2/ios
```

#### Running the app
```
  make run
```

### Possible issues

```
scripts/clangWrap.sh
CMake Error at CMakeLists.txt:36 (find_package):
  By not providing "FindQt5.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "Qt5", but
  CMake did not find one.

```
Fix: Make sure the env variable `QTDIR` points to the qt installation folder


```
ios/mkspecs/features/uikit/devices.py: /usr/bin/python: bad interpreter: No such file or directory
```

Fix: Update `ios/mkspecs/features/uikit/devices.py` header to point to your python installation

```
    from distutils.version import StrictVersion
ModuleNotFoundError: No module named 'distutils'
```

Fix: `pip install setuptools`

```
Simulator device failed to install the application.
The application's Info.plist does not contain a valid CFBundleVersion.
Ensure your bundle contains a valid CFBundleVersion.
```

Fix: Remove `bin/Status-tablet.app` and run `make run`

```
Underlying error (domain=FBSOpenApplicationServiceErrorDomain, code=4):
```

Fix: In the simulator app choose `Device -> Erase all content and settings`

# Android

#### Prerequisites:
- Make sure status-desktop can be built
- Qt 5.15.2 for Android or qt 6.8.3 for Android
- Clone submodules
```
  git submodule update --init --recursive
```

- JDK 11 (17 for qt6)
- Android sdk
- Android NDK 21.3.6528147 (26.1.10909125 for qt6)
- Android emulator
- Android cmd line tools
- Available AVD image

#### Installing qt
```
  pip3 install -U pip
  pip3 install aqtinstall
  aqt install-qt mac android 5.15.2 -O ${QT_INSTALL_DIR}
  #For qt6 autodesktop flag is needed
  #The androiddeployqt is installed in the desktop distribution
  aqt install-qt mac android 6.8.3 android_arm64-v8a --autodesktop

  export QTDIR=${QT_INSTALL_DIR}/5.15.2/android
```

Note: These prerequisites can be installed with AndroidStudio

Or by using the command line tools
```
sudo apt install openjdk-11-jdk
sudo apt install google-android-cmdline-tools-13.0-installer
sdkmanager --update
sdkmanager "build-tools;35.0.1" "emulator" "platform-tools" "platforms;android-31" "ndk;21.3.6528147"

# create a new AVD image. Using the template with id 70
avdmanager create avd -n "Test_avd_x64" -k "system-images;android-Baklava;google_apis_playstore;x86_64" -d 70

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ANDROID_HOME=usr/lib/android-sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:/usr/lib/android-sdk/platform-tools:$PATH"
export ANDROID_NDK_HOME=/usr/lib/android-sdk/ndk/21.3.6528147 
export SDK_PATH="$ANDROID_HOME"
# default architecture is arm64-v8a
export ARCH=<android target>
```

#### Running the app
```
  make run
```

### Known issues

PNG files won't be rendered on macos emulator. This can be fixed by setting the software rendered for qt.
Add `setenv("QT_QUICK_BACKEND", "software", 1);` in main.cpp

gradle is crashing sometimes: Make sure there's enough RAM. Sometimes a restart is needed
the compiler is sometimes crashing while compiling statusQ: Make sure at least 10GB free RAM is available

