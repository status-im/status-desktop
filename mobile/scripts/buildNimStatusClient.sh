#!/bin/sh
set -ef pipefail

make deps-common -j10 

ARCH=${ARCH:="amd64"}
DESKTOP_VERSION=$(eval ./scripts/version.sh)
STATUSGO_VERSION=$(eval cd vendor/status-go; make version)

echo $DESKTOP_VERSION $STATUSGO_VERSION

if [ "$ARCH" == "x86_64" ]; then
    CARCH="amd64"
else
    CARCH="$ARCH"
fi

echo "Building status-client for $ARCH using compiler: $CC"

./vendor/nimbus-build-system/scripts/env.sh nim c -d:release --outdir:./bin -d:DESKTOP_VERSION=$DESKTOP_VERSION -d:STATUSGO_VERSION=$STATUSGO_VERSION -d:GIT_COMMIT="`git log --pretty=format:'%h' -n 1`" -d:chronicles_sinks=textlines[stdout],textlines[nocolors,dynamic],textlines[file,nocolors] -d:chronicles_runtime_filtering=on -d:chronicles_default_output_device=dynamic -d:chronicles_log_level=trace \
    --mm:refc \
    --app:staticlib \
    --opt:speed \
    --cc:clang \
    --cpu:$CARCH \
    --os:macosx \
    -d:ios \
    --noMain:on \
    -d:release \
    --clang.exe=$CC \
    --clang.linkerexe=$CC \
    --dynlibOverrideAll \
    src/nim_status_client.nim 