{ pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/328636cafa83bcdf08b2a4f4e6b7fbcbe4ec56b3.zip";
    sha256 = "sha256:16bzv763l44rfhmv47qlgckcv4cz7n9j3dnp43lg1k0jxxzvbcqs";
  }) { config = { allowBroken = true; }; } }:

let
  inherit (pkgs) lib stdenv;

  qtCustom = with pkgs.qt515;
    env "qt-custom-${qtbase.version}" ([
      qtbase qttools qtdeclarative
      qtlottie qtmultimedia
      qtquickcontrols qtquickcontrols2
      qtsvg qtwebengine
    ]);

  /* Lock requires Xcode verison. */
  xcodeWrapper = pkgs.xcodeenv.composeXcodeWrapper { version = "14.2"; };
in pkgs.mkShell {
  name = "status-desktop-build-shell";

  buildInputs = with pkgs; [
    bash which curl wget git file unzip jq
    gcc cmake go_1_18 gnumake pkg-config gnugrep
    qtCustom pcre nss pcsclite extra-cmake-modules
    xorg.libxcb xorg.libX11 libxkbcommon
  ] ++ (with gst_all_1; [
    gst-libav gstreamer
    gst-plugins-bad  gst-plugins-base
    gst-plugins-good gst-plugins-ugly
  ])
  ++ lib.optional stdenv.isLinux  [ lsb-release ];
  ++ lib.optional stdenv.isDarwin [
    (with darwin.apple_sdk.frameworks; [ CoreServices CoreFoundation ])
  ];

  # Avoid terminal issues.
  TERM = "xterm";
  LANG = "en_US.UTF-8";
  LANGUAGE = "en_US.UTF-8";

  QTDIR = qtCustom;

  shellHook = ''
    export MAKEFLAGS="-j$NIX_BUILD_CORES"
  '';

  # Sandbox causes Xcode issues on MacOS. Requires sandbox=relaxed.
  # https://github.com/status-im/status-mobile/pull/13912
  __noChroot = stdenv.isDarwin;
}
