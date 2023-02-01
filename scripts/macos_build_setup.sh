#!/usr/bin/env bash
set -eo pipefail

GO_VERSION="1.19.5"
GO_INSTALL_DIR="/usr/local/go"
QT_VERSION="5.15.2"
QT_INSTALL_DIR="/usr/local/qt"

function check_version {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "ERROR: Installer intended for MacOS/Darwin!"
    exit 1
  fi
}

function install_build_dependencies {
  echo "Install build dependencies"
  brew install cmake pkg-config libtool jq node@18
}

function install_qt {
  echo "Install QT"
  brew install python@3.10
  pip3 install -U pip
  pip3 install aqtinstall
  aqt install-qt mac desktop ${QT_VERSION} clang_64 -m qtwebengine -O ${QT_INSTALL_DIR}
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
    ["amd64"]="23d22bb6571bbd60197bee8aaa10e702f9802786c2e2ddce5c84527e86b66aa0"
    ["arm64"]="4a67f2bf0601afe2177eb58f825adf83509511d77ab79174db0712dc9efa16c8"
  )
  echo "Install GoLang ${GO_VERSION}"
  GO_ARCH=$(get_go_arch)
  GO_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  GO_TARBALL="go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
  wget -q "https://dl.google.com/go/${GO_TARBALL}" -O "${GO_TARBALL}"
  echo "${GO_SHA256_MAP[${GO_ARCH}]} ${GO_TARBALL}" | sha256sum -c
  tar -C "${GO_INSTALL_DIR%/go}" -xzf "${GO_TARBALL}"
  rm "${GO_TARBALL}"
  ln -s "${GO_INSTALL_DIR}/bin/go" /usr/local/bin
}

function success_message {
  msg="
SUCCESS!

Before you attempt to build status-dektop you'll need a few environment variables set:

export QTDIR=${QT_INSTALL_DIR}/${QT_VERSION}/clang_64
export PATH=\$QTDIR:\$QTDIR/bin:\$PATH
"
  echo $msg
}

if [ "$0" = "$BASH_SOURCE" ]; then
    check_version
    install_build_dependencies
    install_qt
    install_golang
    success_message
fi
