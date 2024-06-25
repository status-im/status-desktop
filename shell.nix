{
  pkgs ? import ./nix/pkgs.nix
}:

let
  qtCustom = (with pkgs.qt515;
    # TODO:check the required modules after Qt upgrade
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
#      qtlottie # TODO: was missing in 5.15.2, review after upgrade
  ]));

in pkgs.mkShell {
  name = "status-desktop-build-shell";

  # TODO:check the required packages after Qt upgrade
  buildInputs = with pkgs; [
    bash curl wget git file unzip jq lsb-release which cacert gnupg
    linuxdeployqt appimagekit
    libglvnd # TODO: Qt 5.15.2 fix, review after upgrade
    cmake_3_19 gnumake pkg-config gnugrep qtCustom
    go_1_21
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
  # TODO: still needed?
  # https://github.com/NixOS/nixpkgs/pull/109649
  QT_INSTALL_PLUGINS = "${qtCustom}/${pkgs.qt515.qtbase.qtPluginPrefix}";

  shellHook = ''
    export PATH="${pkgs.lddWrapped}/bin:$PATH"
  '';

  # Used to workaround missing lib links in qt-custom
  # TODO:check if it's still needed after Qt upgrade
  LIBRARY_PATH = with pkgs.qt515; pkgs.lib.makeLibraryPath [
    qtdeclarative
    qtmultimedia
    qtquickcontrols
    qtquickcontrols2
    qtsvg
    qtwebchannel
    qtwebview
  ];

  # Used for linuxdeployqt
  # TODO:check if qt modules are still needed here after Qt upgrade
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
    p11-kit
    zlib
  ] ++ (with qt515; [
    qtbase
    qtdeclarative
    qtlocation
    qtmultimedia
    qtquickcontrols2
    qtsvg
    qtwebengine
  ]) ++ (with xorg; [
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
    gstreamer
  ]));
}
