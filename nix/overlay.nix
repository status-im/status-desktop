# Override some packages and utilities in 'pkgs'
# and make them available globally via callPackage.
#
# For more details see:
# - https://nixos.wiki/wiki/Overlays
# - https://nixos.org/nixos/nix-pills/callpackage-design-pattern.html

final: prev: let
  inherit (prev) callPackage;
in rec {
  linuxdeployqt = callPackage ./pkgs/linuxdeployqt/default.nix { };

  # Copyied from d9424d2191d6439a276b69ae1fd0a800586135ca
  # 2018-07-27 -> 2020-12-31
  appimagekit = callPackage ./pkgs/appimagekit/default.nix { };

  # Requirement from Makefile - 3.19
  cmake_3_19 = prev.cmake.overrideAttrs ( attrs : rec {
    version = "3.19.7";

    src = prev.fetchurl {
      url = "${attrs.meta.homepage}files/v${prev.lib.versions.majorMinor version}/cmake-${version}.tar.gz";
      # compare with https://cmake.org/files/v${lib.versions.majorMinor version}/cmake-${version}-SHA-256.txt
      sha256 = "sha256-WKFfDVagr8zDzFNxI0/Oc/zGyPnb13XYmOUQuDF1WI4=";
    };
  });

  # Copyied from bootstrap121 from 0e2a36815d2310886458ac1aab14350160e6b12a
  # autoPatchelfHook is disabled
  # TODO: compile, not binary
  go_1_20 = callPackage ./pkgs/go/bootstrap120.nix { };

  # Fix for linuxdeployqt so it's not upset shell interpreter from host system
  lddWrapped = prev.writeShellScriptBin "ldd" ''
    "${final.bash}/bin/sh" "${final.glibc.bin}/bin/ldd" "$@"
  '';
}
