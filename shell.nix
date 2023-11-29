{ pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e7603eba51f2c7820c0a182c6bbb351181caa8e7.zip";
    sha256 = "sha256:0mwck8jyr74wh1b7g6nac1mxy6a0rkppz8n12andsffybsipz5jw";
  }) { } }:

let
  qtCustom = with pkgs.qt515;
    env "qt-custom-${qtbase.version}" ([
      qtquickcontrols2
      qtgraphicaleffects
      qtbase qttools qtdeclarative
      qtlottie qtmultimedia
      qtquickcontrols qtquickcontrols2
      qtsvg qtwebengine qtwebview
    ]);
in pkgs.mkShell {
  name = "status-desktop-build-shell";

  buildInputs = with pkgs; [
    qt5Full
    bash curl wget git file unzip jq lsb-release
    cmake gnumake pkg-config gnugrep qtCustom
    go_1_19
    pcre nss pcsclite extra-cmake-modules
    xorg.libxcb xorg.libX11 libxkbcommon
  ] ++ (with gst_all_1; [
    gst-libav gstreamer
    gst-plugins-bad  gst-plugins-base
    gst-plugins-good gst-plugins-ugly
  ]);

  # Avoid terminal issues.
  TERM = "xterm";
  LANG = "en_US.UTF-8";
  LANGUAGE = "en_US.UTF-8";

  QTDIR = qtCustom;

  shellHook = ''
    export MAKEFLAGS="-j$NIX_BUILD_CORES"
  '';
}
