#!/usr/bin/env bash
set -eof pipefail

if test `find $1 -mmin +1440`; then
    echo "forcing rebuild of status go"
    rm $1
fi
