#!/bin/sh
set -ef pipefail
set -o xtrace

QRCODEGEN=${QRCODEGEN:="../vendors/status-desktop/vendor/QRCodeGen/c"}
LIB_DIR=${LIB_DIR}

echo "Building QRCodeGen for $ARCH using compiler: $CC"
make -C $QRCODEGEN clean
make -C $QRCODEGEN -j$(nproc)

mkdir -p $LIB_DIR
cp $QRCODEGEN/libqrcodegen.a $LIB_DIR/libqrcodegen.a
