#!/bin/sh
set -ef pipefail

PCRE=${PCRE:="../vendors/status-desktop/vendor/pcre"}
LIB_DIR=${LIB_DIR}

BASEDIR=$(dirname "$0")

# Load common config variables
. $BASEDIR/commonCmakeConfig.sh


echo "Building PCRE for $ARCH using compiler: $CC"

if [ "$STATIC_LIB" = "ON" ]; then
    ENABLE_DYNAMIC_LIBS=OFF
    LIB_EXT=.a
    PCRE_LIB_NAME=libpcre$LIB_EXT

else
    LIB_SUFFIX=""
    ENABLE_DYNAMIC_LIBS=ON
    LIB_EXT=.so
    PCRE_LIB_NAME=libpcre$LIB_EXT
fi

cmake -S ${PCRE} -B ${PCRE}/build \
    $COMMON_CMAKE_CONFIG \
    -DPCRE_BUILD_TESTS:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=$ENABLE_DYNAMIC_LIBS \
    -DPCRE_BUILD_PCREGREP:BOOL=OFF


cmake --build ${PCRE}/build --target pcre --config Release --parallel 10

mkdir -p $LIB_DIR

PCRE_LIB=$(find ${PCRE}/build -name $PCRE_LIB_NAME)
cp $PCRE_LIB $LIB_DIR/libpcre$LIB_EXT
