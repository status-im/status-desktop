# This file controls the pinned version of nixpkgs we use for our Nix environment
# as well as which versions of package we use, including their overrides.
let
  # For testing local version of nixpkgs
  #nixpkgsSrc = (import <nixpkgs> { }).lib.cleanSource "/home/jakubgs/work/nixpkgs";

  # We follow the release-24.05 branch of official nixpkgs.
  nixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/29679bde4a9b069f76d6ff26b8d03b62e7f018f4.tar.gz";
    sha256 = "sha256:0cdfnfr0xwcn5y677vy73parlw447krggghrf4lmcv4kmr7j2xjh";
  };

  # Override some packages and utilities
  pkgsOverlay = import ./overlay.nix;
in
  (import nixpkgsSrc) {
    overlays = [ pkgsOverlay ];
  }
