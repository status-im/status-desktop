#!/bin/bash

# Workaround for permissions problems with `jenkins` user inside the container
cp -R . ~/status-desktop
cd ~/status-desktop

git clean -dfx && rm -rf vendor/* && make -j4 V=1 update
make V=1 $1

# Make AppImage build accessible to the docker host
cd - && cp -R ~/status-desktop/pkg/* ./pkg/.

