#!/bin/bash

# Workaround for permissions problems with `jenkins` user inside the container
cp -R . ~/status-desktop
cd ~/status-desktop



git clean -dfx && rm -rf vendor/* && git checkout vendor/DOtherSide && make -j4 V=1 update


sed -i 's|\t\$(MAKE) -C \./third_party/nwaku libwaku|\tsed -i '\''s/c++20/c++2a/g'\'' ./third_party/nwaku/vendor/negentropy/cpp/Makefile; $(MAKE) -C ./third_party/nwaku libwaku|' ./vendor/status-go/Makefile

make V=1 pkg USE_NWAKU=true

# Make AppImage build accessible to the docker host
cd - && cp -R ~/status-desktop/pkg .
chmod -R 775 ./pkg
