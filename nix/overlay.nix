# Override some packages and utilities in 'pkgs'
# and make them available globally via callPackage.
#
# For more details see:
# - https://nixos.wiki/wiki/Overlays
# - https://nixos.org/nixos/nix-pills/callpackage-design-pattern.html

final: prev: let
  inherit (prev) config stdenv callPackage recurseIntoAttrs makeOverridable fetchurl lib writeShellScriptBin __splicedPackages;
in {
  # TODO: Remove once nixpkgs is upgraded.
  mockgen = callPackage ./pkgs/mockgen { };
  protobuf3_20 = callPackage ./pkgs/protobuf { };
  protoc-gen-go = callPackage ./pkgs/protoc-gen-go { };

  linuxdeployqt = callPackage ./pkgs/linuxdeployqt { };

  # Copyied from d9424d2191d6439a276b69ae1fd0a800586135ca
  # 2018-07-27 -> 2020-12-31
  # TODO: override and upgrade
  # Copy is uses because of initial complexity of package override (probably due to fuse override)
  appimagekit = callPackage ./pkgs/appimagekit { };

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
  go_1_22 = callPackage ./pkgs/go/bootstrap122.nix { };
  buildGo122Module = callPackage ./pkgs/go-module { go = final.go_1_22; };

  # Fix for linuxdeployqt running ldd from nix with system shell
  # ERROR: findDependencyInfo: "/bin/sh: /nix/store/HASH-glibc-2.31-74/lib/libc.so.6: version `GLIBC_2.33' not found (required by /bin/sh)\n/bin/sh: /nix/store/0c7c96gikmzv87i7lv3vq5s1cmfjd6zf-glibc-2.31-74/lib/libc.so.6: version `GLIBC_2.34' not found (required by /bin/sh)"
  # $ head $(which ldd)
  # #! /bin/sh
  lddWrapped = writeShellScriptBin "ldd" ''
    "${final.bash}/bin/sh" "${final.glibc.bin}/bin/ldd" "$@"
  '';

  # Qt 5.15.8 copy from 76973ae3b30a88ea415f27ff53809ab8f452e2ec
  # Edited:
  # - temporary break Darwin support
  # - remove unsupported testers, env., config.allowAliases
  # - mkDerivation without finalAttrs
  # - change fetch* parameter from hash to sha256, rmove fetchLFS
  # - fix makeSetupHook
  # - switch from makeScopeWithSplicing back to makeScope
  # See diff for a full list of changes
  qt515_8 = recurseIntoAttrs (makeOverridable
  (import ./pkgs/qt-5/5.15) {
    inherit (__splicedPackages)
      newScope generateSplicesForMkScope lib fetchurl fetchpatch fetchgit fetchFromGitHub makeSetupHook makeWrapper
      bison cups dconf harfbuzz libGL perl gtk3 python3
      darwin buildPackages;
    inherit (__splicedPackages.gst_all_1) gstreamer gst-plugins-base;
    inherit config stdenv;
  });
  alsa-lib = prev.alsaLib;
}
