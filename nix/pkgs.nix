# This file controls the pinned version of nixpkgs we use for our Nix environment
# as well as which versions of package we use, including their overrides.
let
  # For testing local version of nixpkgs
  #nixpkgsSrc = (import <nixpkgs> { }).lib.cleanSource "/home/jakubgs/work/nixpkgs";

  # We follow the release-20.09 branch of official nixpkgs.
  nixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/66b0db71f463164486a36dded50bedee185e45c2.tar.gz";
    sha256 = "sha256:0wam1m12qw9rrijhvbvhm5psj2a0ksms77xzxzyr5laz94j60cb0";
  };

  # Override some packages and utilities
  pkgsOverlay = import ./overlay.nix;
in
  (import nixpkgsSrc) {
    overlays = [ pkgsOverlay ];
  }
