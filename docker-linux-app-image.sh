#!/bin/bash

# Installing prerequisites
# Probably should be part of a dockerfile
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y --fix-missing build-essential cmake git libpcre3-dev

# Installing GO
# Probably should be part of a dockerfile
wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.14.4.linux-amd64.tar.gz
rm ./go1.14.4.linux-amd64.tar.gz
export PATH="/usr/local/go/bin:${PATH}"

# $QT_PATH and $QT_PLATFORM are provided by the docker image
# $QT_PATH/$QT_VERSION/$QT_PLATFORM/bin is already prepended to $PATH
# However $QT_VERSION is not exposed to environment so set it here
export QT_VERSION=$(basename $(echo "${QT_PATH}/*"))
export QTDIR="${QT_PATH}/${QT_VERSION}"
# $OPENSSL_PREFIX is provided by the docker image
export LIBRARY_PATH="${OPENSSL_PREFIX}/lib:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${QTDIR}/${QT_PLATFORM}/lib:${LD_LIBRARY_PATH}"
make clean; git clean -dfx && rm -rf vendor/*
make pkg V=1
