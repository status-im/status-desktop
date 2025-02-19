# IOS

### Running the app

#### Prerequisites:
- Make sure status-desktop can be built
- Qt 5.15.2 for IOS
```
  pip3 install -U pip
  pip3 install aqtinstall
  aqt install-qt mac ios 5.15.2 -O ${QT_INSTALL_DIR}
  ### OR if it fails for arm64
  arch -x86_64 aqt install-qt mac ios 5.15.2 -O ${QT_INSTALL_DIR}/5.15.2/ios

  export QTDIR=${QT_INSTALL_DIR}/5.15.2/ios
```
- Python
- Clone submodules
```
  git submodule update --init --recursive
```
- Xcode
- Ipad pro simulator


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

Fix: Remove `bin/IOS-build.app` and run `make run`

```
Underlying error (domain=FBSOpenApplicationServiceErrorDomain, code=4):
```

Fix: In the simulator app choose `Device -> Erase all content and settings`

# Android

#### Prerequisites:
- Make sure status-desktop can be built
- Qt 5.15.2 for Android
```
  pip3 install -U pip
  pip3 install aqtinstall
  aqt install-qt mac android 5.15.2 -O ${QT_INSTALL_DIR}
  ### OR if it fails for arm64
  arch -x86_64 aqt install-qt mac android 5.15.2 -O ${QT_INSTALL_DIR}/5.15.2/ios

  export QTDIR=${QT_INSTALL_DIR}/5.15.2/android
```
- Python
- Clone submodules
```
  git submodule update --init --recursive
```



Android sdk
Android NDK 21.3.6528147
Android emulator
Android cmd line tools
Note: These prerequisites can be installed with AndroidStudio

JDK 11

#### Running the app
```
  export ANDROID_NDK_HOME=<your ndk path>
  export SDK_PATH=<your sdk path>
  export JAVA_HOME=<your java path>/libexec/openjdk.jdk/Contents/Home
  make run
```

### Known issues

PNG files won't be rendered on macos emulator. This can be fixed by setting the software rendered for qt.
Add `setenv("QT_QUICK_BACKEND", "software", 1);` in main.cpp




