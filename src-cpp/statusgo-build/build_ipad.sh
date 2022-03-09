#!/bin/bash

# build_ipad.sh

GOLIBPATH="$(pwd)/../../vendor/status-go"


export GO111MODULE="on"
export CGO_ENABLED=1 
export GOOS=darwin
export GOARCH=arm64
export SDK=iphoneos 
export CC="$(pwd)/clangwrap.sh"
export CGO_CFLAGS="-I//include -I//include/darwin"

cd $GOLIBPATH
export GOBIN=$(pwd)/build/bin

mkdir -p $GOBIN/statusgo-lib

go env
go run cmd/library/*.go > $GOBIN/statusgo-lib/main.go
go build \
   -buildmode=c-archive -tags ios \
   -o $GOBIN/libstatus.a \
   $GOBIN/statusgo-lib

ls -la $GOBIN/libstatus.*
