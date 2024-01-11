{
  pkgs ? import ./nix/pkgs.nix
}:

let
  qtCustom = (with pkgs.qt515; /* 5.15.8 */
    env "qt-custom-${qtbase.version}" ([
# TODO: to check
      qtbase
      qtdeclarative
      qtlottie
      qtmultimedia
      qtquickcontrols
      qtquickcontrols2
      qtsvg
      qttools
      qtwebengine
# checked
      qtwebchannel
      qtlocation
      qtwebview
      qtgraphicaleffects
      ]));

in pkgs.mkShell {
  name = "status-desktop-build-shell";

  buildInputs = with pkgs; [
    linuxdeployqt
# TODO: to check
    curl wget git file unzip jq lsb-release
    cmake gnumake pkg-config gnugrep qtCustom
    pcre nss pcsclite extra-cmake-modules
    xorg.libxcb xorg.libX11 libxkbcommon
# checked
    which go_1_19 cacert
    appimagekit gnupg
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

  LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
    alsa-lib
    expat
    fontconfig
    freetype
    gcc-unwrapped
    glib
    gmp
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    harfbuzz
    libglvnd
    libkrb5
    libpng
    libpulseaudio
    libxkbcommon
    p11-kit
    xorg.libICE
    xorg.libSM
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    zlib
 ];
}
