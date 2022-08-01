{
  source ? builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c140730d40d723c3c74a8d24bceef363495a3aef.zip";
    sha256 = "sha256:1bcms35idl4mggickf97z6sydyr8iyjjw93iahhzwczwc42dgs0b";
  },
  pkgs ? import (source) { }
}:

let
  qtCustom = with pkgs.qt515; /* 5.15.8 */
    env "qt-custom-${qtbase.version}" ([
      qtbase
      qtdeclarative
      qtlottie
      qtmultimedia
      qtquickcontrols
      qtquickcontrols2
      qtsvg
      qttools
      qtwebengine
    ]);
in pkgs.mkShell {
  name = "status-desktop-build-shell";

  buildInputs = with pkgs; [
    bash which curl wget git file unzip jq lsb-release
    go cmake gnumake pkg-config gnugrep qtCustom
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
  # https://github.com/NixOS/nixpkgs/pull/109649
  QT_INSTALL_PLUGINS = "${qtCustom}/${pkgs.qt515.qtbase.qtPluginPrefix}";

  shellHook = ''
    export MAKEFLAGS="-j$NIX_BUILD_CORES"
  '';
}
