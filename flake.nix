{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-20.09";
  # for nix-shell support
  inputs.flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

  outputs = { self, nixpkgs, flake-compat }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ (import ./nix/overlay.nix) ];
      };
    in {
      devShells.x86_64-linux.default = pkgs.callPackage ./nix/shell.nix { };
    };
}
