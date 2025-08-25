# Enhanced Status Build Runtime

This Dockerfile creates a complete Android build environment for Status Desktop by extending the Qt base image with additional tooling.

## Base Image

Built on top of `statusteam/nim-status-client-build:1.0.0-qt6.9.0-android` which provides:
- Qt 6.9.0 for Android (all architectures)
- Qt 6.9.0 for Desktop (host tools)
- Android SDK and NDK
- Build dependencies

## Additional Components

This enhanced image adds:

### Development Tools
- **Nim 2.0.12**: Programming language and toolchain
- **Nix 2.24.11**: Package manager
- **Go 1.23.10**: Updated Go toolchain with required packages

### Build Dependencies
- **OpenSSL 3.0.15**: Built specifically for Android arm64-v8a
- **Additional system libraries**: Enhanced development environment

### User Configuration
- **Jenkins user**: UID/GID 1001 for CI compatibility
- **Sudo access**: Full sudo privileges for jenkins user
- **Proper PATH**: All tools accessible system-wide

## Image Tags

The Jenkins pipeline produces two images:

1. **Base Qt Image**: `statusteam/nim-status-client-build:1.0.0-qt6.9.0-android`
   - Contains only Qt and essential build tools
   - Smaller image size
   - Good for Qt-only builds

2. **Complete Image**: `statusteam/nim-status-client-build:1.0.0-qt6.9.0-android-ci`
   - Contains everything from base image plus Nim, Nix, enhanced OpenSSL
   - Full Status Desktop build environment
   - Ready for complete Status app builds

## Usage

```bash
docker run -it statusteam/nim-status-client-build:1.0.0-qt6.9.0-android-ci
```

## Environment Variables

Key environment variables set in the image:

```bash
QT_HOST_PATH="/opt/qt/6.9.0/gcc_64/"
QT_PLUGIN_PATH="/opt/qt/6.9.0/gcc_64/plugins"
OPENSSL_LIB_DIR="/home/jenkins/openssl-output/arm64-v8a/lib"
OPENSSL_INC_DIR="/home/jenkins/openssl-output/arm64-v8a/include"
ANDROID_SDK_ROOT="/opt/android-sdk"
ANDROID_NDK_ROOT="/opt/android-sdk/ndk/27.2.12479018"
```
