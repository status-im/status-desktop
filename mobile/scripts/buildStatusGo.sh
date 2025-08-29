#!/usr/bin/env bash
#Script designed to run in the context of the status-go repository
set -ef pipefail
set -o xtrace

STATUS_GO=${STATUS_GO:-"../vendors/status-desktop/vendor/status-go"}
LIB_DIR=${LIB_DIR}

ARCH=${ARCH:-amd64}
OS=${OS:-ios}

GOARCH=${GOARCH:-"amd64"}
if [[ "$ARCH" == "x86_64" ]]; then
	GOARCH="amd64"
else
	GOARCH="$ARCH"
fi

BUILD_MODE=c-archive
LIB_EXT=a
if [[ "$OS" == "android" ]]; then
	BUILD_MODE=c-shared
	LIB_EXT=so
fi

echo "Building status-go for $ARCH using compiler: $CC"

cd "$STATUS_GO"

if [[ "$OS" == "android" ]]; then
	echo "Generating android SDS bindings"
	export ANDROID_TARGET=28
	export ANDROID_NDK_HOME="/opt/android-sdk/ndk/27.2.12479018/"
	make generate-sds-android V=3 SHELL=/bin/sh
	cp $STATUS_GO/vendor/github.com/waku-org/sds-go-bindings/third_party/nim-sds/build/libsds.so "$LIB_DIR/libsds.$LIB_EXT"
fi

make generate V=3 SHELL=/bin/sh

mkdir -p build/bin/statusgo-lib
GOOS=$(shell go env GOHOSTOS) GOARCH=$(shell go env GOHOSTARCH) \
	go run cmd/library/main.go cmd/library/const.go > build/bin/statusgo-lib/main.go

GOFLAGS="" CGO_CFLAGS="-Os -flto" CGO_LDFLAGS="-Os -flto" CGO_ENABLED=1 GOOS="$OS" GOARCH="$GOARCH" \
	go build \
		-buildmode="$BUILD_MODE" \
		-tags 'gowaku_no_rln nowatchdog disable_torrent' \
		-ldflags="-checklinkname=0 -X github.com/status-im/status-go/vendor/github.com/ethereum/go-ethereum/metrics.EnabledStr=true" \
		-o "$LIB_DIR/libstatus.$LIB_EXT" \
		./build/bin/statusgo-lib

echo "status-go build complete"
