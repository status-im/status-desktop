#!/bin/bash

# This script assumes $PWD is the same dir in which this script is located

docker run -it --rm --device /dev/fuse \
  -v "${PWD}:/nim-status-client:Z" \
  -w /nim-status-client \
  --cap-add SYS_ADMIN \
  --privileged \
  a12e/docker-qt:5.14-gcc_64 \
  ./docker-linux-app-image.sh
