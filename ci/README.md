# Description

These `Jenkinsfile`s are used to run CI jobs in Jenkins. You can find them here:
https://ci.status.im/job/nim-status-client/

# Builds

## Linux

In order to build the Linux version of the application we use a modified `a12e/docker-qt:5.14-gcc_64` Docker image with the addition of Git and Golang.

The image is built with [`Dockerfile`](./Dockerfile) using:
```
docker build -t statusteam/nim-status-client-build:latest .
```
And pushed to: https://hub.docker.com/r/statusteam/nim-status-client-build

## MacOS

The MacOS builds are run on MacOS hosts and expect Command Line Toold and XCode to be installed, as well as QT being available under `/usr/local/qt`.

It also expects the presence of the following credentials:

* `macos-keychain-identity` - ID of used signing certificate.
* `macos-keychain-pass` - Password to unlock the keychain.
* `macos-keychain-file` - Keychain file with the MacOS signing certificate.

You can read about how to create such a keychain [here](https://github.com/status-im/infra-docs/blob/master/articles/macos_signing_keychain.md).
