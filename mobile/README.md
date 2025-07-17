
# Status Mobile Build System

This repository contains the build system for Status Mobile, supporting both iOS and Android platforms with Qt6 compatibility.
Cross-compilation is currently supported on MacOs and Linux. Windows is not supported. The dev setup runs well on WSL with Windows emulator.

## Table of Contents
- [Quick Start Guide (Container Builds) - Android](#quick-start-guide-container-builds)
- [Developer Setup Guide](DEV_SETUP.md)
- [Build System Documentation](DEV_SETUP.md#build-system-documentation)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Contributing](CONTRIBUTING.md)

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
brew install act android-platform-tools android-commandlinetools xcbeautify
```

```bash
# Ubuntu
sudo apt-get update
sudo apt install android-sdk-common

sdkmanager --install \
"build-tools;35.0.1" \
"emulator" \
"platform-tools" \
"platforms;android-35" \
"ndk;27.2.12479018" \
"system-images;android-35;google_apis;arm64-v8a"
```

- Install [act](https://nektosact.com/installation/index.html)

2. **Verify installation:**
```bash
adb --version
emulator --version
avdmanager --version
sdkmanager --version
act --version
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
