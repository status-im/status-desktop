
# 🛠️ Status Desktop Build Guide

This guide provides step-by-step instructions to build Status Desktop from source on **Windows**, **Linux**, and **macOS**.


## 📑 Table of Contents

- [1️⃣ Prerequisites](#1️⃣-prerequisites)
  - [Windows](#windows)
  - [Linux](#linux)
    - [Ubuntu](#ubuntu)
    - [Fedora](#fedora)
  - [macOS](#macos)
- [2️⃣ Install Qt](#2️⃣-install-qt)
  - [Windows & Linux](#windows--linux)
  - [Linux (Alternative)](#linux-alternative)
- [3️⃣ Configure Environment](#3️⃣-configure-environment)
  - [Windows](#windows-1)
  - [Linux](#linux-1)
- [4️⃣ Build the App](#4️⃣-build-the-app)
- [🐞 Troubleshooting](#-troubleshooting)
- [📬 Need Further Help?](#-need-further-help)

## 1️⃣ Prerequisites

### Windows

#### Install Chocolatey

Install [Chocolatey](https://chocolatey.org/install) by running the following command in an **Administrator** PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = `
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### Install Required Packages

Run with **Administrator** privileges:

```powershell
choco install make cmake mingw wget
```

#### Install Go 1.23

Download and install Go 1.23 from the [official website](https://go.dev/dl/).

> ⚠️ Note: 1.23 version is a strict requirement for now. Version 1.24 won't work

> ⚠️ Note: There is a script `scripts/windows_build_setup.ps1`, but it may be outdated.

### Linux

#### Ubuntu

Install required packages:

```bash
sudo apt update
sudo apt install libpcsclite-dev libpcre3-dev build-essential mesa-common-dev libglu1-mesa-dev libssl-dev cmake jq libxcb-xinerama0 protobuf-compiler
```

Install **libssl 1.1** (if not available in your distribution):

```bash
wget https://launchpad.net/~ubuntu-security-proposed/+archive/ubuntu/ppa/+build/23606713/+files/libssl1.1_1.1.1l-1ubuntu1.3_amd64.deb
sudo dpkg -i libssl1.1_1.1.1l-1ubuntu1.3_amd64.deb
```

Install **Go 1.23**:

Download and install from the [official website](https://go.dev/dl/).

Install **nvm** (Node Version Manager):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
```

Add the following to your `.bashrc` or `.zshrc`:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Install Node.js (LTS version):

```bash
nvm install --lts
nvm alias default lts/*
npm install -g npm@latest
```

#### Fedora

Install required packages:

```bash
sudo dnf install pcsc-lite-devel pcre-devel openssl-devel protobuf-devel protobuf-compiler
```

If **OpenSSL 1.1** is not available:

```bash
sudo dnf install perl-FindBin perl-File-Compare perl-File-Copy perl-Pod-Html
wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
tar xvf openssl-1.1.1w.tar.gz
cd openssl-1.1.1w
./config --prefix=$HOME/.local/lib/openssl1.1
make && make install
```

Install **nvm** and Node.js as per the [Ubuntu instructions above](#ubuntu).


### macOS

#### Install Homebrew

Install [Homebrew](https://brew.sh/) if not already installed.

#### Install Required Packages

```bash
brew install cmake pkg-config go@1.23 qt@5 protobuf 
```

Install additional packages if you are planning to build DMG

```bash
brew install nvm yarn fileicon
```

#### Export GITHUB_USER and GITHUB_TOKEN environment variables

`status-desktop` uses Homebrew to download precompiled binary packages ("bottles") from GitHub.
Sometimes, Homebrew can hit GitHub's API rate limits, causing builds to fail.
To avoid this, you can generate a [GitHub personal access token](https://github.com/settings/personal-access-tokens) and export it in your environment:


```shell
export GITHUB_TOKEN=github_pat_YOURSUPERSECRETTOKENDONOTSHARE
export GITHUB_USER=yourgithubname
```


#### Install Node.js

> [!TIP]
> You can skip this step if not planning to build a DMG

Create NVM's working directory:

```bash
mkdir ~/.nvm
```

Add the following to your shell profile (`~/.zshrc`, `~/.bash_profile`, etc.):

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
```

Install Node.js (LTS version):

```bash
nvm install --lts
nvm alias default lts/*
npm install -g npm@latest
```

Install additional dependencies:

```bash
npm install fileicon
brew install coreutils
```

#### Install Python Dependencies

> [!TIP]
> You can skip this step if not planning to build a DMG

If using Python ≥ 3.12:

```bash
python3 -m pip install setuptools --break-system-packages
```


## 2️⃣ Install Qt

### Windows & Linux

Install **Qt 5.15.2** using the [Qt Online Installer](https://www.qt.io/download).

### Linux (Alternative)

You can use any newer 5.15.x version available in your system's package manager.

#### Ubuntu

```bash
sudo apt install qtbase5-dev qt5-qmake qtquickcontrols2-5-dev
```

#### Fedora

```bash
sudo dnf install qt5-qtbase qt5-qtbase-devel qt5-qtquickcontrols
```


## 3️⃣ Configure Environment

### Windows

Set environment variables:

```powershell
$env:QTPATH = "C:\Qt\5.15.2\5.15.2"
$env:QTBASE = "C:\Qt\5.15.2"
$env:QTDIR = "C:\Qt\5.15.2\msvc2017_64"
$env:GOPATH = "C:\Users\{your_username}\go\bin"
$env:VCINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC"
$env:VS160COMNTOOLS = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build"
```

Add the following paths to your `PATH` environment variable:

```
C:\ProgramData\chocolatey\bin
C:\Users\{your_username}\scoop\apps\mingw\current\bin
C:\Users\{your_username}\scoop\apps\cmake\3.31.6\bin
C:\Users\{your_username}\scoop\apps\mingw\15.1.0-rt_v12-rev0\bin
С:\Users\{your_username}\go\bin
C:\Program Files\Go\bin
C:\Qt\5.15.2\msvc2019_64\bin
C:\protoc-30.2-win64\bin
C:\Qt\Tools\Ninja
C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin
C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin
C:\Users\{your_username}\AppData\Local\Programs\Microsoft VS Code\bin
```

### Linux

If you installed Qt via your system's package manager, additional environment configuration may not be necessary.

Otherwise, set those envirionment variables:
```shell
export QTDIR="/path/to/Qt/5.15.2/gcc_64"
export PATH="${QTDIR}/bin:${PATH}"
```


## 4️⃣ Build the App

> **📝 Note:** On Windows, all commands should be executed under **Git Bash**.
.

Clone the repository:

```bash
git clone https://github.com/status-im/status-desktop.git
cd status-desktop
```

Install some `status-go` dependencies:

```bash
make status-go-deps
```

Make sure you have `~/go/bin` in your `PATH`:
```bash
echo "export PATH=\"$HOME/go/bin:\$PATH\"" >> ~/.zshrc
```

Update all submodules and build the dependencies:

```bash
make update
```

> Tip: Nim takes a long compile. Try using the `-j8` flag where 8 is the number of cores you want to allocate

Build and run the app:

```bash
make run
```
🎉


## 🐞 Troubleshooting

### Qt Not Found

Make sure your `QTDIR` and `PATH` are correctly set. You can also try:

```bash
export QTDIR=/path/to/Qt/5.15.2/gcc_64
export PATH=$QTDIR/bin:$PATH
```

### Application doesn't build

Get more log output:

```bash
make run V=1
```

## 📬 Need Further Help?

If you get stuck or something doesn't work:

- Ask in `#feedback-desktop` channel on [Status](https://status.app/cc/G-EAAORobqgnsUPSVCLaSJr855iXTIdQiY1Q0ckBe8dWWEBpUAs9s8DTjWEpvsmpE83Izx1JWQuZrWWKUoxiXCwdtB-wPBzyvv_n9a0F61xTaPZE7BEJDC7Ly_WcmQ4tHRAKnPfXE_JUtEX_3NhnXQN0eh4ue0D77dWvaDpDrSi0U0CaGLZ-pqD_iV0z9RMFE2LKulDZdwL40etJ8lxjyTFoxS0lUhdWKinIOk8qBmJJpCmsqMrSklEU#zQ3shZeEJqTC1xhGUjxuS4rtHSrhJ8vUYp64v6qWkLpvdy9L9)
- Open an [issue on GitHub](https://github.com/status-im/status-desktop/issues)

