#!/bin/sh

ARCH=${ARCH:=amd64}

echo "Building QRCodeGen for $ARCH using compiler: $CC"

ARCH=$ARCH CC=$CC make -j10 2>&1