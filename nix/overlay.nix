# Override some packages and utilities in 'pkgs'
# and make them available globally via callPackage.
#
# For more details see:
# - https://nixos.wiki/wiki/Overlays
# - https://nixos.org/nixos/nix-pills/callpackage-design-pattern.html

final: prev: let
  inherit (prev) config stdenv callPackage recurseIntoAttrs makeOverridable fetchurl lib writeShellScriptBin;
#  makeScopeWithSplicing' generateSplicesForMkScope
#  writeShellScriptBin __splicedPackages
#  makeSetupHook fetchgit fetchpatch fetchFromGitHub makeWrapper
#  bison cups harfbuzz libGL perl python3
#  gstreamer gst-plugins-base gtk3 dconf
#  llvmPackages_15 darwin;
in rec {
  linuxdeployqt = callPackage ./pkgs/linuxdeployqt/default.nix { };

  # Copyied from d9424d2191d6439a276b69ae1fd0a800586135ca
  # 2018-07-27 -> 2020-12-31
  # TODO: override and upgrade
  # Copy is uses because of initial complexity of package override (probably due to fuse override)
  appimagekit = callPackage ./pkgs/appimagekit/default.nix { };

  # Requirement from Makefile - 3.19
  cmake_3_19 = prev.cmake.overrideAttrs ( attrs : rec {
    version = "3.19.7";

    src = fetchurl {
      url = "${attrs.meta.homepage}files/v${lib.versions.majorMinor version}/cmake-${version}.tar.gz";
      # compare with https://cmake.org/files/v${lib.versions.majorMinor version}/cmake-${version}-SHA-256.txt
      sha256 = "sha256-WKFfDVagr8zDzFNxI0/Oc/zGyPnb13XYmOUQuDF1WI4=";
    };
  });

  # Copyied from bootstrap121 from 020300a756e75ea9ce86a8ab5ee259c31e28ed43
  # - autoPatchelfHook is disabled
  # - development/compilers/go/print-hashes.sh 1.21.11
  # TODO: compile, not binary
  # Binary is used because of initial complexity of both package override and copy from newer nixpkgs
  go_1_21 = callPackage ./pkgs/go/bootstrap121.nix { };

  # Fix for linuxdeployqt running ldd from nix with system shell
  # ERROR: findDependencyInfo: "/bin/sh: /nix/store/HASH-glibc-2.31-74/lib/libc.so.6: version `GLIBC_2.33' not found (required by /bin/sh)\n/bin/sh: /nix/store/0c7c96gikmzv87i7lv3vq5s1cmfjd6zf-glibc-2.31-74/lib/libc.so.6: version `GLIBC_2.34' not found (required by /bin/sh)"
  # $ head $(which ldd)
  # #! /bin/sh
  lddWrapped = writeShellScriptBin "ldd" ''
    "${final.bash}/bin/sh" "${final.glibc.bin}/bin/ldd" "$@"
  '';


  qt515_14 = callPackage ./pkgs/qt-5/5.15/default.nix {
#    inherit lib stdenv fetchurl fetchgit fetchpatch fetchFromGitHub makeSetupHook makeWrapper makeScopeWithSplicing';
#    inherit bison cups harfbuzz libGL perl python3;
#    inherit gstreamer gst-plugins-base gtk3 dconf;
#    inherit llvmPackages_15;
#    inherit darwin;
#    inherit generateSplicesForMkScope;
#
#    overrideSDK = prev.darwin.overrideSDK or (x: x);
#    overrideLibcxx = prev.darwin.overrideLibcxx or (x: x);
#
#    # Options
#    developerBuild = false;
#    decryptSslTraffic = false;
#    debug = false;
#    inherit config;
};


  alsa-lib = prev.alsaLib;
}
