# IOS-build

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

#### Running the app
```
  make run
```

### Issues

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