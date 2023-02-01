#!/usr/bin/env bash
set -eo pipefail

GO_VERSION="1.19.5"
GO_INSTALL_DIR="/usr/local/go"
QT_VERSION="5.15.2"
QT_INSTALL_DIR="/opt/qt"

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
  aqt install-qt linux desktop ${QT_VERSION} gcc_64 -m qtwebengine -O ${QT_INSTALL_DIR}
}

function get_go_arch {
  case "$(uname -m)" in
    "x86_64")  echo "amd64" ;;
    "aarch64") echo "arm64" ;;
    "armv*")   echo "armv6l" ;;
    *)         echo "UNKNOWN" ;;
  esac
}

function install_golang {
  if [[ -x "$(command -v go)" ]]; then
    echo "Already present: $(go version)"
    return
  fi
  declare -A GO_SHA256_MAP
  GO_SHA256_MAP=(
    ["amd64"]="36519702ae2fd573c9869461990ae550c8c0d955cd28d2827a6b159fda81ff95"
    ["arm64"]="fc0aa29c933cec8d76f5435d859aaf42249aa08c74eb2d154689ae44c08d23b3"
    ["armv6l"]="ec14f04bdaf4a62bdcf8b55b9b6434cc27c2df7d214d0bb7076a7597283b026a"
  )
  echo "Install GoLang ${GO_VERSION}"
  GO_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  GO_ARCH=$(get_go_arch)
  GO_TARBALL="go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
  wget -q "https://dl.google.com/go/${GO_TARBALL}" -O "${GO_TARBALL}"
  echo "${GO_SHA256_MAP[${GO_ARCH}]} ${GO_TARBALL}" | sha256sum -c
  tar -C "${GO_INSTALL_DIR}" -xzf "${GO_TARBALL}"
  rm "${GO_TARBALL}"
  ln -s "${GO_INSTALL_DIR}/go/bin/go" /usr/local/bin
}

function success_message {
  msg="
SUCCESS!

Before you attempt to build status-dektop you'll need a few environment variables set:

export QTDIR=${QT_INSTALL_DIR}/${QT_VERSION}/gcc_64
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
