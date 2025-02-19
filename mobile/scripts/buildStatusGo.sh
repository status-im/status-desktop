#!/bin/sh
#Script designed to run in the context of the status-go repository
set -o xtrace

STATUS_GO=${STATUS_GO:="../vendors/status-desktop/vendor/status-go"}
LIB_DIR=${LIB_DIR}

ARCH=${ARCH:=amd64}
OS=${OS:=ios}

GOARCH=${GOARCH:="amd64"}
if [ "$ARCH" = "x86_64" ]; then
	GOARCH="amd64"
else
	GOARCH=$ARCH
fi

BUILD_MODE=c-archive
LIB_EXT=a
if [ "$OS" = "android" ]; then
	BUILD_MODE=c-shared
	LIB_EXT=so
fi

echo "Building status-go for $ARCH using compiler: $CC"

cd $STATUS_GO
make generate

mkdir -p build/bin/statusgo-lib
go run cmd/library/*.go > build/bin/statusgo-lib/main.go

CGO_ENABLED=1 GOOS=$OS GOARCH=$GOARCH \
	go build \
		-buildmode=$BUILD_MODE \
		-tags 'gowaku_no_rln nowatchdog disable_torrent' \
		-ldflags="-X github.com/status-im/status-go/vendor/github.com/ethereum/go-ethereum/metrics.EnabledStr=true" \
		-o $LIB_DIR/libstatus.$LIB_EXT \
		./build/bin/statusgo-lib

echo "status-go build complete"
