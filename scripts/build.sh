#!/usr/bin/env bash
set -e

function echo_make() {
    echo -n "$1 - "
    make $1 >/dev/null 2>&1 && echo SUCCESS || echo FAILURE
}

function build_client() {
    echo_make dotherside
    echo_make statusq
    echo_make check-qt-dir
    echo_make status-go
    echo_make status-keycard-go
    echo_make vendor/QR-Code-generator/c/libqrcodegen.a
    echo_make ./fleets.json
    echo_make rcc
    echo_make compile-translations 
    echo_make deps
    echo_make bin/nim_status_client
}

echo START
export MAKEFLAGS="-j$(nproc)"
make update >/dev/null 2>&1
for i in {0..200}; do
    build_client || { echo FAILURE; exit 1; }
    rm -f bin/nim_status_client
done
echo END
