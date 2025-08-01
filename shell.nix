{
  pkgs ? import ./nix/pkgs.nix
}:

let
  qtCustom = (with pkgs.qt515_8;
    # TODO:check the required modules
    env "qt-custom-${qtbase.version}" ([
      qtbase
      qtdeclarative
      qtquickcontrols
      qtquickcontrols2
      qtsvg
      qtmultimedia
      qtwebview
      qttools
      qtwebchannel
      qtgraphicaleffects
      qtwebengine
      qtlocation
  ]));

in pkgs.mkShell {
  name = "status-desktop-build-shell";

  # TODO:check the required packages
  buildInputs = with pkgs; [
    bash curl wget git file unzip jq lsb-release which cacert gnupg
    linuxdeployqt appimagekit
    libglvnd # TODO: Qt 5.15.2 fix, review after upgrade
    cmake_3_19 gnumake pkg-config gnugrep qtCustom
    go_1_22 go-bindata mockgen protobuf3_20 protoc-gen-go
    nss pcsclite extra-cmake-modules
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
  # TODO: still needed?
  # https://github.com/NixOS/nixpkgs/pull/109649
  QT_INSTALL_PLUGINS = "${qtCustom}/${pkgs.qt515_8.qtbase.qtPluginPrefix}";

  shellHook = ''
    export MAKEFLAGS="-j$NIX_BUILD_CORES"
    export PATH="${pkgs.lddWrapped}/bin:$PATH"
  '';

  LIBKRB5_PATH = pkgs.libkrb5;
  QTWEBENGINE_PATH = pkgs.qt515_8.qtwebengine.out;
  GSTREAMER_PATH = pkgs.gst_all_1.gstreamer;
  NSS_PATH = pkgs.nss;

  # Used for linuxdeployqt
  # TODO:check which deps are needed
  LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath (
  [
    alsaLib
    expat
    fontconfig
    freetype
    gcc-unwrapped
    glib
    gmp
    harfbuzz
    libglvnd
    libkrb5
    libpng
    libpulseaudio
    libxkbcommon
    openexr
    openssl
    p11-kit
    zlib
  ] ++ (with xorg; [
    libICE
    libSM
    libX11
    libXrender
    libxcb
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ]) ++ (with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gstreamer
  ]));
}
