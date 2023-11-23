{
  pkgs ? import ./pkgs.nix
}:

let
  lddWrapped = pkgs.writeShellScriptBin "ldd" ''
    sh "${pkgs.glibc.bin}/bin/ldd" "$@"
  '';
in
  pkgs.mkShell {
    name = "debug-shell";
    buildInputs = with pkgs; [
      lddWrapped which
    ];

    shellHook = ''
      export PATH="${lddWrapped}/bin:$PATH"
    '';

    #LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
    #  glibc
    #];
  }
