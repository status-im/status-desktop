# This file controls the pinned version of nixpkgs we use for our Nix environment
# as well as which versions of package we use, including their overrides.
let
  # For testing local version of nixpkgs
  #nixpkgsSrc = (import <nixpkgs> { }).lib.cleanSource "/home/jakubgs/work/nixpkgs";

  # We follow the master branch of official nixpkgs.
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e7603eba51f2c7820c0a182c6bbb351181caa8e7.tar.gz";
    sha256 = "sha256:0mwck8jyr74wh1b7g6nac1mxy6a0rkppz8n12andsffybsipz5jw";
  };

  #nixpkgsSrc = (import <nixpkgs> { }).lib.cleanSource "/home/jakubgs/work/nixpkgs";


  # glibc 2.24
  #nixpkgs-old = import "nixpkgs/release-16.09";
  #nixpkgs-old = builtins.fetchTarball {
  #  url = "https://github.com/NixOS/nixpkgs/archive/52ef8b0d0d66055e799325f0b65d4ecb30f44e49.tar.gz";
  #  #sha256 = "sha256:0mwck8jyr74wh1b7g6nac1mxy6a0rkppz8n12andsffybsipz5jw";
  #};

  # Glibc 2.31
  #nixpkgsSrcOld = import "nixpkgs/nixos-20.09"
  # TODO: maybe -small ?
  nixpkgs-old = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/1c1f5649bb9c1b0d98637c8c365228f57126f361.tar.gz";
    # TODO: find sha
    #sha256 = "sha256:0mwck8jyr74wh1b7g6nac1mxy6a0rkppz8n12andsffybsipz5jw";
  };

  # Override some packages and utilities
  pkgsOverlay = import ./overlay.nix { inherit nixpkgs; inherit nixpkgs-old; };

in
  (import nixpkgs) {
    overlays = [ pkgsOverlay ];
  }
