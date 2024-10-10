{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-20.09";
  # for nix-shell support
  inputs.flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

  # pinned last commit which works with nixpkgs 20.09
  inputs.nixgl = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:nix-community/nixGL/643e730efb981ffaf8478f441ec9b9aeea1c89f5";
  };

  outputs = { self, nixpkgs, nixgl, flake-compat }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ (import ./nix/overlay.nix) nixgl.overlay ];
      };
    in {
      devShells.x86_64-linux.default = pkgs.callPackage ./nix/shell.nix { };
    };
}
