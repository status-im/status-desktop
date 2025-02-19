#!/bin/sh
set -ef pipefail

DOTHERSIDE=${DOTHERSIDE:="../vendors/status-desktop/vendor/DOtherSide"}
LIB_DIR=${LIB_DIR}

BASEDIR=$(dirname "$0")

# Load common config variables
. $BASEDIR/commonCmakeConfig.sh
BUILD_DIR=$DOTHERSIDE/build/$OS

if [ "$STATIC_LIB" = "ON" ]; then
    ENABLE_DYNAMIC_LIBS=OFF
    ENABLE_STATIC_LIBS=ON
    LIB_EXT=.a
    DOTHERSIDE_LIB_NAME=libDOtherSideStatic$LIB_EXT

else
    LIB_SUFFIX=""
    if [ "$OS" = "android" ]; then
        LIB_SUFFIX=_$ANDROID_ABI
        LIB_EXT=".so"
    fi
    ENABLE_DYNAMIC_LIBS=ON
    ENABLE_STATIC_LIBS=OFF
    LIB_EXT=.so
    DOTHERSIDE_LIB_NAME=libDOtherSide$LIB_SUFFIX$LIB_EXT
fi

echo "Building DOtherSide for $ARCH using compiler: $CC"

cmake -S $DOTHERSIDE -B $BUILD_DIR \
    $COMMON_CMAKE_CONFIG \
    -DENABLE_DOCS:BOOL=OFF \
    -DENABLE_DYNAMIC_LIBS:BOOL=$ENABLE_DYNAMIC_LIBS \
    -DENABLE_STATIC_LIBS:BOOL=$ENABLE_STATIC_LIBS \
    -DENABLE_TESTS:BOOL=OFF

make -C $BUILD_DIR -j $(nproc)

DOTHERSIDE_LIB=$(find $BUILD_DIR -name $DOTHERSIDE_LIB_NAME)

mkdir -p $LIB_DIR
cp $DOTHERSIDE_LIB $LIB_DIR/libDOtherSide$LIB_SUFFIX$LIB_EXT