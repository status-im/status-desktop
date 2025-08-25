FROM ubuntu:noble
RUN \
 apt-get update \
 && apt-get -y install python3-pip \
 python3.12-venv \
 strace \
 patchelf \
 squashfs-tools \
 zsync \
 cmake \
 git \
 && export MAKEFLAGS="-j$(nproc)" \
 && python3 -m venv venv && venv/bin/pip3 install git+https://github.com/AppImageCrafters/appimage-builder.git@main

RUN \
 apt-get -y autoremove \
 && apt-get -y autoclean \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*