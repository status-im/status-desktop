#!/bin/sh
#Script designed to run in the context of the status-go repository

ARCH=${ARCH:=amd64}

GOARCH=${GOARCH:="amd64"}
if [ "$ARCH" = "x86_64" ]; then
	GOARCH="amd64"
else
	GOARCH=$ARCH
fi

echo "Building status-go for $ARCH $CXX $SDK $IOS_TARGET using compiler: $CC"

make generate

mkdir -p build/bin/statusgo-lib
go run cmd/library/*.go > build/bin/statusgo-lib/main.go

CGO_ENABLED=1 GOOS=ios GOARCH=$GOARCH \
	go build \
		-buildmode=c-archive \
		-tags 'gowaku_no_rln nowatchdog disable_torrent' \
		-ldflags="-X github.com/status-im/status-go/vendor/github.com/ethereum/go-ethereum/metrics.EnabledStr=true" \
		-o build/bin/libstatus.a \
		./build/bin/statusgo-lib

