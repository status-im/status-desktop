#!/bin/sh
set -ef pipefail

BASEDIR=$(dirname "$0")

# Load common config variables
. $BASEDIR/commonCmakeConfig.sh

STATUSQ=${STATUSQ:="../vendors/status-desktop/ui/StatusQ"}
LIB_DIR=${LIB_DIR}

LIB_SUFFIX=""
LIB_EXT=".a"

if [ "$OS" = "android" ]; then
    LIB_SUFFIX=_$ANDROID_ABI
    LIB_EXT=".so"
fi

BUILD_DIR=$STATUSQ/build/$OS/StatusQ


echo "Building StatusQ for $ARCH using compiler: $CC with CMAKE_TOOLCHAIN_FILE $CMAKE_TOOLCHAIN_FILE"

echo $COMMON_CMAKE_CONFIG

cmake -S $STATUSQ -B $BUILD_DIR \
    $COMMON_CMAKE_CONFIG \
    -DSTATUSQ_BUILD_SANDBOX=OFF \
    -DSTATUSQ_BUILD_SANITY_CHECKER=OFF \
    -DSTATUSQ_BUILD_TESTS=OFF \
    -DSTATUSQ_STATIC_LIB=$STATIC_LIB

make -C $BUILD_DIR qzxing -j $(nproc)
make -C $BUILD_DIR StatusQ -j $(nproc)

mkdir -p $LIB_DIR

STATUSQ_LIB=$(find $BUILD_DIR -name "libStatusQ${LIB_SUFFIX}${LIB_EXT}")
QZXING_LIB=$(find $BUILD_DIR -name "libqzxing.a") 

cp ${STATUSQ_LIB} $LIB_DIR/libStatusQ${LIB_SUFFIX}${LIB_EXT}
cp ${QZXING_LIB} $LIB_DIR/libqzxing.a