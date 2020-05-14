#!/bin/bash
docker run -it --rm --device /dev/fuse \
  -v $PWD:/nim-status-client:Z \
  -w /nim-status-client \
  --cap-add SYS_ADMIN \
  --privileged \
  a12e/docker-qt:5.12-gcc_64 \
  sh build-in-docker.sh
