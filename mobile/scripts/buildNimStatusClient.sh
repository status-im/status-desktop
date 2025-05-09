#!/bin/sh
set -ef pipefail
set -o xtrace

STATUS_DESKTOP=${STATUS_DESKTOP:="../vendors/status-desktop"}
ARCH=${ARCH:="amd64"}
ANDROID_ABI=${ANDROID_ABI:="arm64-v8a"}
LIB_DIR=${LIB_DIR}
LIB_SUFFIX=${LIB_SUFFIX:=""}
OS=${OS:="android"}
HOST_ENV=${HOST_ENV}

DESKTOP_VERSION=$(eval cd $STATUS_DESKTOP && ./scripts/version.sh)
STATUSGO_VERSION=$(eval cd $STATUS_DESKTOP/vendor/status-go && make version --no-print-directory)

if [ "$ARCH" = "x86_64" ]; then
    CARCH="amd64"
else
    CARCH="$ARCH"
fi

if [ "$OS" = "ios" ]; then
    PLATFORM_SPECIFIC="--app:staticlib -d:ios --os:ios -d:chronicles_sinks=textlines[stdout],textlines[nocolors,dynamic],textlines[file,nocolors]"
else
    PLATFORM_SPECIFIC="--app:lib --os:android -d:android -d:androidNDK -d:chronicles_sinks=textlines[syslog],textlines[nocolors,dynamic],textlines[file,nocolors]"
    PLATFORM_SPECIFIC="$PLATFORM_SPECIFIC --passL="-L$LIB_DIR" --passL="-lstatus" --passL="-lStatusQ$LIB_SUFFIX" --passL="-lDOtherSide$LIB_SUFFIX" --passL="-lqrcodegen" --passL="-lqzxing" --passL="-lpcre" --passL="-lssl_1_1" --passL="-lcrypto_1_1" -d:taskpool"
fi

echo "Building status-client for $ARCH using compiler: $CC"

cd $STATUS_DESKTOP
# build nim compiler with host env

# run make deps-common with sytem environment variables found in $HOST_ENV, not with the one from shell configured for android
# build nim compiler with host env
env -i HOME="$HOME" bash -l -c 'make deps-common'

# setting compile time feature flags
FEATURE_FLAGS="FLAG_DAPPS_ENABLED=0 FLAG_CONNECTOR_ENABLED=0 FLAG_KEYCARD_ENABLED=0 FLAG_SINGLE_STATUS_INSTANCE_ENABLED=0"

# build status-client with feature flags
env $FEATURE_FLAGS ./vendor/nimbus-build-system/scripts/env.sh nim c $PLATFORM_SPECIFIC --outdir:./bin -d:DESKTOP_VERSION=$DESKTOP_VERSION -d:STATUSGO_VERSION=$STATUSGO_VERSION -d:GIT_COMMIT="`git log --pretty=format:'%h' -n 1`" -d:chronicles_runtime_filtering=on -d:chronicles_default_output_device=file -d:chronicles_log_level=trace \
    --mm:refc \
    --opt:speed \
    --cc:clang \
    --cpu:$CARCH \
    --noMain:on \
    -d:release \
    --clang.exe=$CC \
    --clang.linkerexe=$CC \
    --dynlibOverrideAll \
    --nimcache:$STATUS_DESKTOP/nimcache \
    $STATUS_DESKTOP/src/nim_status_client.nim

mkdir -p $LIB_DIR

cp $STATUS_DESKTOP/bin/libnim_status_client$LIB_EXT $LIB_DIR/libnim_status_client$LIB_EXT

