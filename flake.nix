{
  description = "Status Desktop - Development environment with Qt 6.9.2";

  nixConfig = {
    extra-substituters = [
      "https://nix-cache.status.im/"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "nix-cache.status.im-1:x/93lOfLU+duPplwMSBR+OlY4+mo+dCN7n0mr4oPwgY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    stalled-download-timeout = 3600;
    connect-timeout = 10;
    max-jobs = "auto";
  };

  inputs = {
    # Use nixpkgs with Qt 6.9.2 (commit from August 27, 2025)
    nixpkgs.url = "github:NixOS/nixpkgs/5c99d67b8618876563e7b9eacf7567cc62aeb7fd";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    nixpkgsFor = forAllSystems (system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    });
  in {
    devShells = forAllSystems (system:
    let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        name = "status-desktop-dev";

        buildInputs = with pkgs; [
          # Core build tools
          cmake
          gnumake
          pkg-config
          git

          # Go toolchain
          go_1_24

          # Qt 6.9.2
          qt6.full

          # GCC
          gcc13
        ];

        shellHook = ''
          echo "Status Desktop Development Environment"
          echo "======================================"
          echo ""
          echo "Qt version: $(qmake -query QT_VERSION)"
          echo "Go version: $(go version | cut -d' ' -f3)"
          echo "GCC version: $(gcc --version | head -n1)"
          echo ""

          # Set Qt environment
          export QTDIR="${pkgs.qt6.qtbase}"
          export QT_PLUGIN_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
          export QML2_IMPORT_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtQmlPrefix}"
          export QMAKESPEC="linux-g++"

          # Disable Qt disk cache
          export QML_DISABLE_DISK_CACHE=true

          # Set compiler
          export CC="${pkgs.gcc13}/bin/gcc"
          export CXX="${pkgs.gcc13}/bin/g++"

          # Set locale
          export LANG=en_US.UTF-8

          echo "Ready to build!"
          echo ""
        '';

        # Environment variables
        TERM = "xterm";
        QT_QPA_PLATFORM = "xcb";
      };
    });
  };
}
