# making a local packaged build
git clean -dfx

# Build .deb
docker run -it --rm \
  --cap-add SYS_ADMIN \
  --security-opt apparmor:unconfined \
  --device /dev/fuse \
  -u jenkins:$(getent group $(whoami) | cut -d: -f3) \
  -v "${PWD}:/status-desktop" \
  -w /status-desktop \
  statusteam/status-desktop-deb-build:latest \
  sh ./scripts/docker-linux.sh deb-linux
