#!/bin/sh
#Script designed to run in the context of the status-go repository

#Make sure CC is properly set
#CC=clangwrap.sh

ARCH=${ARCH:=amd64}
GOARCH=${GOARCH:="amd64"}
if [ "$ARCH" = "x86_64" ]; then
	GOARCH="amd64"
else
	GOARCH=$ARCH
fi

echo "Building status-go for $ARCH using compiler: $CC"

make generate 2>&1

mkdir -p build/bin/statusgo-lib 2>&1
go run cmd/library/*.go > build/bin/statusgo-lib/main.go 2>&1

CGO_ENABLED=1 GOOS=ios GOARCH=$GOARCH CC=$CC \
	go build \
		-buildmode=c-archive \
		-tags 'gowaku_no_rln nowatchdog disable_torrent' \
		-ldflags="-X github.com/status-im/status-go/vendor/github.com/ethereum/go-ethereum/metrics.EnabledStr=true" \
		-o build/bin/libstatus.a \
		./build/bin/statusgo-lib 2>&1

