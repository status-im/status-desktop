---
title: "Installation"
description: ""
lead: ""
date: 2020-11-16T13:59:39+01:00
lastmod: 2020-11-16T13:59:39+01:00
draft: false
images: []
menu:
  docs:
    parent: "intro"
weight: 110
toc: true
---

## MacOs

* Download the Status DMG file from the [status site](https://status.im/get/) or from [github releases](https://github.com/status-im/status-desktop/releases).
* Open the DMG and drag the status icon to the Application folder. If prompted, click `Replace to overwrite a previous version.
* When opening the newly copied app for the first time: `control+click -> Open -> OK` then `control+click -> Open -> Open`.

### Backing up data folder

Installing a new app should re-use the same data folder, it is recommended however you back up your data folder
* Open Finder and in the menu bar click `Go.`
* Select `Go To Folder...`, type or paste `~/Library/Application Support/Status` and then press Return.
* Backup this Status folder somewhere else.

## Linux

* Download the Status AppImage file from the [status site](https://status.im/get/) or from [github releases](https://github.com/status-im/status-desktop/releases).
* Make the downloaded .AppImage file executable: chmod +x StatusIm-Desktop*.AppImage.

### Backing up data folder

Backup the `~/.config/Status` directory if you need it.

## Windows

* Download the Status ZIP file from the [status site](https://status.im/get/) or from [github releases](https://github.com/status-im/status-desktop/releases).
* If you are upgrading from a previous version:
  * Press the Start button and select `Run` (or press the Windows Key + R), type or paste `%LOCALAPPDATA%\Status` and then press Enter.
  * Backup this Status folder somewhere else if you need it then delete it.
* Extract contents of the downloaded `.zip` file and copy the extracted Status folder to your preferred location.
* When opening Status.exe, if a dialog reports “Microsoft Defender SmartScreen prevented an unrecognized app from starting” then you will need to partially disable SmartScreen:
  * Press the Start button (or press the Windows Key), type or paste `Windows Security` and then press Enter.
  * Open the `App & browser control` panel and toggle off `Check apps and files`.
* When opening Status.exe, if a dialog warns “The publisher could not be verified. Are you sure you want to run this software?” you can press the `Run` button to safely proceed. You may be prompted twice. This warning is expected for beta releases of the Status Desktop app for Windows.
* When opening Status.exe, if a dialog reports a missing DLL then you will need to run `bin\vc_redist.x64.exe` inside the extracted Status folder to install the missing Microsoft component. This is usually necessary only for older versions of Windows.

### Backing up data folder

* Press the Start button, select `Run` (or Windows Key + R) and type: `%LOCALAPPDATA%\Status`.
* Backup this folder somewhere else if you need it.
* After backup, remove the folder and move the unzipped Status folder to your preferred location.

## Building from source

### 0. Prerequesites

On windows you can simply run the [`scripts/windows_build_setup.ps1`](../scripts/windows_build_setup.ps1) script in a PowerShell with Administrator privileges.

* QT

**IMPORTANT:** Due to [a bug](https://github.com/status-im/status-desktop/commit/7b07a31fa6d06c730cf563475d319f0217a211ca) in version `5.15.0`, this project is locked to version `5.14.2`. Make sure to select version `5.14.2` when installing Qt via the installer.

Linux users should install Qt through the system's package manager:

```
# Debian/Ubuntu:
sudo apt install qtbase5-dev qtdeclarative5-dev qml-module-qt-labs-platform qtquickcontrols2-5-dev

# Fedora
sudo dnf install qt-devel qt5-devel

```

If that's not possible, manually install QT from https://www.qt.io/download-qt-installer
and add it to the PATH

```
# Linux
export PATH=$PATH:/path/to/Qt/5.14.2/gcc_64/bin

# macos
export PATH=$PATH:/path/to/Qt/5.14.2/clang_64/bin
```

* Go - (used to build status-go)

```
# Linux
<TODO>

# macOS
brew install go
```

### 1. Install QT, and add it to the PATH

```
# Linux users should use their distro's package manager, but in case they do a manual install:
export QTDIR="/path/to/Qt/5.14.2/gcc_64"
export PATH="${QTDIR}/bin:${PATH}"

# macOS:
export QTDIR="/path/to/Qt/5.14.2/clang_64"
export PATH="${QTDIR}/bin:${PATH}"
```

### 2. Clone the repo and build `nim-status-client`
```
git clone https://github.com/status-im/nim-status-client
cd nim-status-client
make update
make
```

For more output use `make V=1 ...`.

Use 4 CPU cores with `make -j4 ...`.

Users with manually installed Qt5 packages need to run `make QTDIR="/path/to/Qt" ...`

**Troubleshooting**:

If the `make` command fails due to already installed Homebrew packages, such as:

```
Error: protobuf 3.11.4 is already installed
To upgrade to 3.11.4_1, run `brew upgrade protobuf`.
make[1]: *** [install-os-dependencies] Error 1
make: *** [vendor/status-go/build/bin/libstatus.a] Error 2
```

This can be fixed by uninstalling the package e.g. `brew uninstall protobuf` followed by rerunning `make`.


### 3. Run the app

```
make run
# or
LD_LIBRARY_PATH=vendor/DOtherSide/lib ./bin/nim_status_client
```

### Development

If only making changes in QML `ui/` re-rerunning the app is enough
If making changes in the nim code `src/` then doing `make` again is needed (it's very fast after the first run)