#!/bin/sh

CWD=$(realpath `dirname $0`)

mkdir -p $CWD/../build
cd $CWD/../build
qmake $CWD/../wrapperApp/IOS-build.pro -spec macx-ios-clang CONFIG+=release CONFIG+=iphonesimulator CONFIG+=simulator -after
make -j10

# WORKAROUND: build twice..The qrc dependency order is not correct
qmake $CWD/../wrapperApp/IOS-build.pro -spec macx-ios-clang CONFIG+=release CONFIG+=iphonesimulator CONFIG+=simulator -after
make -j10