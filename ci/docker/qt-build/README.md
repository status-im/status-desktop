# Qt Build Pipeline for Status

This directory contains the Docker build pipeline for creating Qt images used by Status Desktop/Mobile builds. 
This replaces the dependency on third-party Docker images to mitigate supply chain attack risks.

## Overview

```
ci/docker/qt-build/
├── appimage-builder/
│   └── Dockerfile            # Base Ubuntu image with build tools
├── base/
│   └── Dockerfile            # Qt development base with Android SDK/NDK
├── qt/
│   └── Dockerfile            # Final Qt image with binaries
├── scripts/
│   ├── build_qt_android.sh  # Builds Qt for Android
│   └── build_qt_desktop.sh  # Builds Qt for Desktop
└── README.md                # This file
```

The build pipeline creates a Qt 6.9.0 Docker image with Android support, built entirely from source under our control.

### Image Hierarchy

1. **appimage-builder** (Ubuntu Noble base)
   - Base Ubuntu image with AppImage build tools
   
2. **qt-dev-base** (builds on appimage-builder)
   - Adds development tools, Android SDK/NDK
   - Includes all Qt build dependencies
   
3. **qt** (final image, builds on qt-dev-base)
   - Contains pre-built Qt binaries for:
     - Linux amd64
     - Linux arm64
     - Android (arm64-v8a, armeabi-v7a, x86, x86_64)

## Jenkins Pipeline

The Jenkins pipeline (`ci/Jenkinsfile.qt-build`) handles the generation of QT Android Docker Image:

### Parameters

- `QT_VERSION`: Qt version to build (default: 6.9.0)
- `DOCKER_TAG`: Tag for the final Docker image (default: 1.0.0-qt6.9.0-android)
- `PUSH_TO_DOCKERHUB`: Whether to push the image to DockerHub (default: true)
- `BUILD_QT_FROM_SOURCE`: Build Qt from source vs using cached binaries (default: true)

### Stages

1. **Build AppImage Builder**: Creates the base Ubuntu image
2. **Build Qt Dev Base**: Adds development tools and Android SDK/NDK
3. **Build Qt Binaries**: Compiles Qt from source (if enabled)
   - Desktop builds (amd64, arm64)
   - Android builds (all architectures)
4. **Build Final Qt Image**: Assembles the final Docker image
5. **Test Image**: Validates the built image
6. **Push to DockerHub**: Publishes to `statusteam/nim-status-client-build`

## Building Qt from Source

The first build must be done from source (set `BUILD_QT_FROM_SOURCE=true`). This process:

1. Clones Qt 6.9.0 source code
2. Builds FFmpeg for Android
3. Builds OpenSSL for Android
4. Compiles Qt for all target platforms
5. Creates tar archives of the built binaries

**Note**: Building from source takes several hours (upto 4 hours depending on hardware).

## Maintenance

### Updating Qt Version

1. Update `QT_VERSION` in the scripts
2. Test the build locally or in a dev environment
3. Run the Jenkins pipeline with the new version
4. Update dependent Dockerfiles to use the new image tag
