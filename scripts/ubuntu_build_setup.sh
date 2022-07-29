#!/usr/bin/env bash
set -eo pipefail

function check_version {
  source /etc/os-release
  
  if [[ "$NAME" != "Ubuntu" ]] || ! [[ "$VERSION" =~ ^20\.04 ]]; then
    echo "ERROR: Ubuntu version is not 20.04.4"
    exit 1
  fi
}

function install_dependencies {
  echo "Install dependencies"
  apt update
  apt install -yq git build-essential python3.8 python3-pip pkg-config mesa-common-dev \
     libglu1-mesa-dev wget libpcsclite-dev libpcre3-dev libssl-dev libpulse-mainloop-glib0 \
     libxkbcommon-x11-dev extra-cmake-modules cmake

}

function install_qt {
  echo "Install QT"
  pip install -U pip
  pip install aqtinstall
  aqt install-qt linux desktop 5.14.2 gcc_64 -m qtwebengine qtlottie -O /opt/qt
}

function install_golang {
  echo "Install GoLang"
  export GOLANG_SHA256="6e5203fbdcade4aa4331e441fd2e1db8444681a6a6c72886a37ddd11caa415d4"
  export GOLANG_TARBALL="go1.17.12.linux-amd64.tar.gz"
  wget -q "https://dl.google.com/go/${GOLANG_TARBALL}"
  echo "${GOLANG_SHA256} ${GOLANG_TARBALL}" | sha256sum -c
  tar -C /usr/local -xzf "${GOLANG_TARBALL}"
  rm "${GOLANG_TARBALL}"
  ln -s /usr/local/go/bin/go /usr/local/bin
}

function success_message {
  msg="
SUCCESS!

Before you attempt to build status-dektop you'll need a few environment variables set:

export QTDIR=/opt/qt/5.14.2/gcc_64
export PATH=\$PATH:\$QTDIR:\$QTDIR/bin
"
  echo $msg
}

if [ "$0" = "$BASH_SOURCE" ]; then
    check_version
    install_dependencies
    install_qt
    install_golang
    success_message
fi
