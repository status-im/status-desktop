#!/usr/bin/env bash
set -eo pipefail

function check_version {
  source /etc/os-release
  
  if [[ "$NAME" != "Ubuntu" ]] || ! [[ "$VERSION" =~ ^20\.04 ]]; then
    echo "ERROR: Ubuntu version is not 20.04.4"
    exit 1
  fi
}

function install_build_dependencies {
  echo "Install build dependencies"
  apt update
  apt install -yq git build-essential pkg-config mesa-common-dev \
     libglu1-mesa-dev wget libpcsclite-dev libpcre3-dev libssl-dev libpulse-mainloop-glib0 \
     libxkbcommon-x11-dev extra-cmake-modules cmake
}

function install_release_dependencies {
  echo "Install release dependencies"
  mkdir -p /usr/local/bin
  curl -Lo/usr/local/bin/linuxdeployqt "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
  chmod a+x /usr/local/bin/linuxdeployqt

  apt install -yq gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
      gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
      gstreamer1.0-alsa gstreamer1.0-pulseaudio
}

function install_runtime_dependencies {
  echo "Install runtime dependencies"
  # xvfb is needed in order run squish test into a headless server 
  apt install -yq libxcomposite-dev xvfb libxft-dev
}

function install_qt {
  echo "Install QT"
  apt install -y python3-pip
  pip install -U pip
  pip install aqtinstall
  aqt install-qt linux desktop 5.14.2 gcc_64 -m qtwebengine qtlottie -O /opt/qt
}

function install_golang {
  if ! [[ -x "$(command -v go)" ]]; then
    echo "Install GoLang"
    export GOLANG_SHA256="006f6622718212363fa1ff004a6ab4d87bbbe772ec5631bab7cac10be346e4f1"
    export GOLANG_TARBALL="go1.18.5.linux-arm64.tar.gz"
    wget -q "https://dl.google.com/go/${GOLANG_TARBALL}"
    echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c
    tar -C /usr/local -xzf "${GOLANG_TARBALL}"
    rm "${GOLANG_TARBALL}"
    ln -s /usr/local/go/bin/go /usr/local/bin
  fi
}

function success_message {
  msg="
SUCCESS!

Before you attempt to build status-dektop you'll need a few environment variables set:

export QTDIR=/opt/qt/5.14.2/gcc_64
export PATH=\$QTDIR:\$QTDIR/bin:\$PATH
"
  echo $msg
}

if [ "$0" = "$BASH_SOURCE" ]; then
    check_version
    install_build_dependencies
    install_release_dependencies
    install_runtime_dependencies
    install_qt
    install_golang
    success_message
fi
