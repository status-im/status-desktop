{
  pkgs ? import ./pkgs.nix
}:

let
  qtCustom = with pkgs.qt515; /* 5.15.8 */
    env "qt-custom-${qtbase.version}" ([
# TODO: double check
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
    ]);

  lddWrapped = pkgs.writeShellScriptBin "ldd" ''
    "${pkgs.bash}/bin/sh" "${pkgs.glibc.bin}/bin/ldd" "$@"
  '';
in pkgs.mkShell {
  name = "status-desktop-build-shell";

  shellHook = ''
    export PATH="${lddWrapped}/bin:$PATH"
    '';
    #export PATH=${pkgs.bashInteractive}/bin:$PATH
    #export SHELL=${pkgs.bashInteractive}/bin

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
# TODO why not glibc? nix build shell issue?
#glibc
#stdenv.cc.cc.lib
 ];
}
