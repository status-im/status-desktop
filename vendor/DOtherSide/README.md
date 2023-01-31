# DOtherSide
[![License](https://img.shields.io/badge/license-LGPL-green.svg)](https://github.com/filcuc/DOtherSide/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/filcuc/DOtherSide.svg?branch=master)](https://travis-ci.org/filcuc/DOtherSide)
[![Build status](https://ci.appveyor.com/api/projects/status/ufufhtv2h507sd96/branch/master?svg=true)](https://ci.appveyor.com/project/filcuc/dotherside/branch/master)
[![codecov](https://codecov.io/gh/filcuc/dotherside/branch/master/graph/badge.svg)](https://codecov.io/gh/filcuc/dotherside)
[![Documentation Status](https://img.shields.io/badge/read-documentation-blue.svg)](https://filcuc.github.io/DOtherSide/)

C language library for creating bindings for the Qt QML language.

Documentation: https://filcuc.github.io/DOtherSide/index.html

Currently the DOtherSide library is used by the following bindings:
* [nimqml](https://github.com/filcuc/nimqml), QML bindings for the Nim programming language
* [dqml](https://github.com/filcuc/dqml), QML bindings for the D programming language
* [qml-rust](https://github.com/White-Oak/qml-rust), QML bindings for the Rust programming language

## Supported features
The following features are implementable from a binding language
* Creating custom QObject
* Creating custom QAbstractListModels
* Creating custom properties, signals and slots
* Creating from QML QObject defined in the binded language
* Creating from Singleton QML QObject defined in the binded language

## Prebuilt binaries
### Windows
Currently we provide the prebuilt binaries for windows through the
github [releases](https://github.com/filcuc/DOtherSide/releases) page

### Linux
Currently we provide the prebuilt binaries for the following
Linux distributions through the [OpenSUSE OBS service](https://build.opensuse.org/package/show/home:filcuc/DOtherSide)
* ```Archlinux``` : [here](http://software.opensuse.org/download.html?project=home%3Afilcuc&package=DOtherSide)

## Change log
The project change log can be read [here](./CHANGELOG.md).

## Supported platforms
Currently we support the following platforms/compilers:
- Linux both 32/64bit with gcc
- Windows 32/64bit with Visual Studio 2013|2015 Community Edition

## Build requirements
You need the following software:
* Qt 5.4 or higher
* Linux: gcc 4.8 or later with c++11 support or higher
* Windows: Visual Studio 2013|2015 Community Edition (Windows) or higher

## Build instructions:
1. Open a shell terminal inside the cloned repo
2. mkdir build && cd build
3. cmake ..
4. make

## Install Instructions
Once you built the package just type
```
make install
```
by default cmake will install to the default CMAKE prefix.
If you want to customize this location type the following command
during the build steps when invoking cmake
```
cmake -DCMAKE_INSTALL_PREFIX:PATH=/path/to/install/prefix path/to/CMakeLists.txt
```
