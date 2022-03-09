#!/bin/bash

# build_android.sh

GOLIBPATH="$(pwd)/../../vendor/status-go"

ANDROID_OUT=../android/app/src/main/jniLibs
ANDROID_SDK=$(HOME)/Library/Android/sdk
NDK_BIN=$(ANDROID_SDK)/ndk/21.0.6113669/toolchains/llvm/prebuilt/darwin-x86_64/bin

GOOS=android \
GOARCH=arm64 \
CC=$(NDK_BIN)/aarch64-linux-android21-clang

export GO111MODULE="on"
export CGO_ENABLED=1 
export GOOS=android
export GOARCH=arm64
export CC=$(NDK_BIN)/aarch64-linux-android21-clang

cd $GOLIBPATH
export GOBIN=$(pwd)/build/bin

mkdir -p $GOBIN/statusgo-lib

go run cmd/library/*.go > $GOBIN/statusgo-lib/main.go
go build \
   -buildmode=c-archive \
   -o $GOBIN/libstatus.a \
   $GOBIN/statusgo-lib

ls -la $GOBIN/libstatus.*
