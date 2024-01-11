# This file controls the pinned version of nixpkgs we use for our Nix environment
# as well as which versions of package we use, including their overrides.
let
  # For testing local version of nixpkgs
  #nixpkgsSrc = (import <nixpkgs> { }).lib.cleanSource "/home/jakubgs/work/nixpkgs";

  # We follow the release-23.05 branch of official nixpkgs.
  nixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e7603eba51f2c7820c0a182c6bbb351181caa8e7.tar.gz";
    sha256 = "sha256:0mwck8jyr74wh1b7g6nac1mxy6a0rkppz8n12andsffybsipz5jw";
  };

  # Override some packages and utilities
  pkgsOverlay = import ./overlay.nix;
in
  (import nixpkgsSrc) {
    overlays = [ pkgsOverlay ];
  }
