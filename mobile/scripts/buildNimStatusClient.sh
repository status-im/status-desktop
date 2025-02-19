#!/bin/sh
set -ef pipefail
set -o xtrace

STATUS_DESKTOP=${STATUS_DESKTOP:="../vendors/status-desktop"}
ARCH=${ARCH:="amd64"}
ANDROID_ABI=${ANDROID_ABI:="arm64-v8a"}
LIB_DIR=${LIB_DIR}
OS=${OS:="android"}
HOST_ENV=${HOST_ENV}

DESKTOP_VERSION=$(eval cd $STATUS_DESKTOP && ./scripts/version.sh)
STATUSGO_VERSION=$(eval cd $STATUS_DESKTOP/vendor/status-go; make version)

echo $DESKTOP_VERSION $STATUSGO_VERSION

if [ "$ARCH" == "x86_64" ]; then
    CARCH="amd64"
else
    CARCH="$ARCH"
fi

if [ "$OS" = "ios" ]; then
    PLATFORM_SPECIFIC="--app:staticlib -d:ios --os:macosx"
    LIB_EXT=".a"
else
    PLATFORM_SPECIFIC="--app:lib --os:android -d:android -d:androidNDK -d:danger"
    PLATFORM_SPECIFIC+=" --passL:"-L$LIB_DIR" \
                        --passL:"-lstatus" \
                        --passL:"-lStatusQ_$ANDROID_ABI" \
                        --passL:"-lDOtherSide_$ANDROID_ABI" \
                        --passL:"-lqrcodegen" \
                        --passL:"-lqzxing" \
                        --passL:"-lpcre" \
                        --passL:"-lssl_1_1" \
                        --passL:"-lcrypto_1_1" \
                        -d:taskpool "

    LIB_EXT=".so"
fi

echo "Building status-client for $ARCH using compiler: $CC"

cd $STATUS_DESKTOP
# build nim compiler with host env

# run make deps-common with sytem environment variables found in $HOST_ENV, not with the one from shell configured for android
# build nim compiler with host env
# build nim compiler with host env
env -i $HOST_ENV make deps-common -j$(nproc)

# build status-client
./vendor/nimbus-build-system/scripts/env.sh nim c $PLATFORM_SPECIFIC -d:release --outdir:./bin -d:DESKTOP_VERSION=$DESKTOP_VERSION -d:STATUSGO_VERSION=$STATUSGO_VERSION -d:GIT_COMMIT="`git log --pretty=format:'%h' -n 1`" -d:chronicles_sinks=textlines[stdout],textlines[nocolors,dynamic],textlines[file,nocolors] -d:chronicles_runtime_filtering=on -d:chronicles_default_output_device=file -d:chronicles_log_level=trace \
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

