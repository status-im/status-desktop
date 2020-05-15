#!/bin/sh

# Probably should be part of a dockerfile
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y --fix-missing cmake build-essential git libpcre3-dev libssl-dev git

rm -Rf tmp
make clean

# Installing GO
# Probably should be part of a dockerfile
wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.14.2.linux-amd64.tar.gz
rm ./go1.14.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# the minor Qt version keeps getting updated inside the Docker image
cd /nim-status-client/
export PKG_CONFIG_PATH="$(echo /opt/qt/*/gcc_64/lib/pkgconfig)"
export LD_LIBRARY_PATH="$(echo /opt/qt/*/gcc_64/lib/)"

make appimage

rm -Rf tmp