#!/usr/bin/env bash
set -eo pipefail

GO_VERSION="1.22.10"
GO_INSTALL_DIR="/usr/local/go"
QT_VERSION="5.15.16_1"
# https://github.com/Homebrew/homebrew-core/commit/2c1970eb750f254ecac6640e7e816fd77a5e065e
QT_BREW_FORMULA_COMMIT_SHA="2c1970eb750f254ecac6640e7e816fd77a5e065e"
QT_FORMULA_URL="https://raw.githubusercontent.com/Homebrew/homebrew-core/${QT_BREW_FORMULA_COMMIT_SHA}/Formula/q/qt%405.rb"
BREW_PREFIX=$(brew --prefix)
QT_INSTALL_DIR="${BREW_PREFIX}/Cellar/qt@5/${QT_VERSION}"

function check_version {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "ERROR: Installer intended for MacOS/Darwin!"
    exit 1
  fi
}

function install_build_dependencies {
  echo "Install build dependencies"
  brew install cmake pkg-config libtool jq node@18 yarn protoc-gen-go
}

function install_qt {
  echo "Installing QT ${QT_VERSION}"

  echo "Detected Homebrew prefix: ${BREW_PREFIX}"
  echo "Qt will be installed to: ${QT_INSTALL_DIR}"

  curl -o qt@5.rb "${QT_FORMULA_URL}"
  brew install ./qt@5.rb
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
    ["amd64"]="dd2c4ac3702658c2c20e3a8b394da1917d86156b2cb4312c9d2f657f80067874"
    ["arm64"]="21cf49415ffe0755b45f2b63e75d136528a32f7bb7bdd0166f51d22a03eb0a3f"
  )
  echo "Install GoLang ${GO_VERSION}"
  GO_ARCH=$(get_go_arch)
  GO_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  GO_TARBALL="go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
  # example: https://dl.google.com/go/go1.22.10.darwin-amd64.tar.gz
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

export QTDIR=${QT_INSTALL_DIR}
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
