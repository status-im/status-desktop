{
  pkgs ? import ./nix/pkgs.nix
}:

let

  qtCustom = (with pkgs.qt515;
    env "qt-custom-${qtbase.version}" ([
## TODO:check again after Qt upgrade
      qtbase
      qtdeclarative
      qtquickcontrols
      qtquickcontrols2
      qtsvg
      qtmultimedia
      qtwebview
      qttools
      qtwebchannel
#      qtlottie # return after qt upgrade ?
#      qtwebengine
#      qtlocation
#      qtgraphicaleffects

  ]));

in pkgs.mkShell {
  name = "status-desktop-build-shell";

  buildInputs = with pkgs; [
# TODO:check again after Qt upgrade
    linuxdeployqt
    libglvnd # Qt 5.15.2 fix, review after upgrade
    curl wget git file unzip jq lsb-release
    cmake_3_19 gnumake pkg-config gnugrep qtCustom
    pcre nss pcsclite extra-cmake-modules
    xorg.libxcb xorg.libX11 libxkbcommon
    which go_1_20 cacert
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
# TODO: still needed?
# https://github.com/NixOS/nixpkgs/pull/109649
  QT_INSTALL_PLUGINS = "${qtCustom}/${pkgs.qt515.qtbase.qtPluginPrefix}";


  shellHook = ''
    export PATH="${pkgs.lddWrapped}/bin:$PATH"
    '';

# Used to workaround missin lib links in qt-custom
# TODO:check again after Qt upgrade
  LIBRARY_PATH = with pkgs.qt515; pkgs.lib.makeLibraryPath [
    qtdeclarative
    qtquickcontrols
    qtsvg
    qtmultimedia
    qtwebview
    qtwebchannel
  ];

# Used for linuxdeployqt
# TODO:check again after Qt upgrade
  LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
    qt515.qtquickcontrols2
    qt515.qtdeclarative
    qt515.qtmultimedia
    qt515.qtbase
    qt515.qtsvg
    libglvnd
    gcc-unwrapped
    libpulseaudio
    glib
    alsaLib
    expat
    fontconfig
    freetype
    gmp
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    harfbuzz
    libkrb5
    libpng
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
    xorg.libX11
    xorg.libxcb
    xorg.xcbutil
    ];
}


