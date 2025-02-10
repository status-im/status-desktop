#!/bin/sh
set -ef pipefail

ARCH=${ARCH:=amd64}

echo "Building QRCodeGen for $ARCH using compiler: $CC"

ARCH=$ARCH CC=$CC make -j10 