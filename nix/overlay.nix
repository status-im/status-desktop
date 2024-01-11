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
}
