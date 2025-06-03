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

  # FIXME: remove this additional source when nixpkgs is upgraded to include OpenSSL 3
  # We use a commit from nixos-21.11 for OpenSSL 3 compatibility
  opensslNixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31.tar.gz";
    sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
  };

  # Override some packages and utilities
  pkgsOverlay = import ./overlay.nix;

  # FIXME: remove this additional source when nixpkgs is upgraded to include OpenSSL 3
  opensslOverlay = final: prev:
  let
    newerPkgs = import opensslNixpkgsSrc { inherit (prev) system; };
  in {
    openssl_3 = newerPkgs.openssl_3_0;
  };

in
  (import nixpkgsSrc) {
    overlays = [ pkgsOverlay opensslOverlay ];
  }
