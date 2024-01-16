# Override some packages and utilities in 'pkgs'
# and make them available globally via callPackage.
#
# For more details see:
# - https://nixos.wiki/wiki/Overlays
# - https://nixos.org/nixos/nix-pills/callpackage-design-pattern.html

final: prev: let
  inherit (prev) callPackage;
in rec {
  linuxdeployqt = callPackage ./pkgs/linuxdeployqt/default.nix { inherit (prev.qt515) qmake; };

  # Copyied from d9424d2191d6439a276b69ae1fd0a800586135ca
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
  #go_1_20 = callPackage ./pkgs/go/1.20.nix {
  #  Foundation = null;
  #  Security = null;
  #  testers = null;
  #  buildGo120Module = null;
  #};

  # Issue fixed, see https://github.com/golang/go/issues/42136
  binutils_2_33-unwrapped = prev.binutils-unwrapped.overrideAttrs ( attrs : rec {
    version = "2.33.1";
    basename = "binutils";
    src = prev.fetchurl {
      url = "mirror://gnu/binutils/${basename}-${version}.tar.bz2";
      sha256 = "1cmd0riv37bqy9mwbg6n3523qgr8b3bbm5kwj19sjrasl4yq9d0c";
    };
    patches = [];
  });

  binutils_2_33 = prev.wrapBintoolsWith {
    bintools = binutils_2_33-unwrapped;
  };
}
