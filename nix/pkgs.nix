# This file controls the pinned version of nixpkgs we use for our Nix environment
# as well as which versions of package we use, including their overrides.
let
  # For testing local version of nixpkgs
  #nixpkgsSrc = (import <nixpkgs> { }).lib.cleanSource "/home/jakubgs/work/nixpkgs";

  # We follow the release-20.09 branch of official nixpkgs.
  nixpkgsSrc = builtins.fetchTarball {
#TODO: pin commit and fix checksum
    url = "https://github.com/NixOS/nixpkgs/archive/release-20.09.tar.gz";
    #url = "https://github.com/NixOS/nixpkgs/archive/66b0db71f463164486a36dded50bedee185e45c2.tar.gz";
    #sha256 = "sha256:0mwck8jyr74wh1b7g6nac1mxy6a0rkppz8n12andsffybsipz5jw";
  };

  # Override some packages and utilities
  pkgsOverlay = import ./overlay.nix;
in
  (import nixpkgsSrc) {
    overlays = [ pkgsOverlay ];
  }
