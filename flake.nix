{
  description = "Status Desktop - Development environment with Qt 6.9.2 and build tooling";

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

      # Golang 1.24.7 (matching Dockerfile)
      go_1_24 = pkgs.go_1_24 or pkgs.go_1_23;	

      # Build dependencies matching CI/Dockerfile
      buildInputs = with pkgs; [
        # Core build tools
        cmake
        gnumake
        pkg-config
        git
        which
        file
        unzip
        wget
        curl
        jq

        # Qt 6 and required modules (from nixpkgs)
        qt6.full
        qt6.qtbase
        qt6.qtdeclarative
        qt6.qtquickcontrols2
        qt6.qtsvg
        qt6.qtmultimedia
        qt6.qtwebview
        qt6.qtwebchannel
        qt6.qtwebengine
        qt6.qtwebsockets
        qt6.qt5compat
        qt6.qtpositioning
        qt6.qtserialport
        qt6.qtshadertools
        qt6.qtimageformats
        qt6.qtscxml
        qt6.qthttpserver

        # Go toolchain - version 1.24.7 from Dockerfile
        go_1_24

        # Protobuf
        protobuf
        protoc-gen-go

        # PCSC Lite 2.2.3 (matching Dockerfile)
        pcsclite

        # GCC 13 (gcc11 removed from nixpkgs, using newer version)
        gcc13
        gcc13.cc.lib

        # System libraries for Qt
        libglvnd
        libxkbcommon

        # X11 libraries (matching Dockerfile dependencies)
        xorg.libX11
        xorg.libxcb
        xorg.libXext
        xorg.libXrender
        xorg.libxkbfile
        xorg.libXrandr
        xorg.libXcursor
        xorg.libXi
        xorg.libXtst
        xorg.libXcomposite
        xorg.xcbutilrenderutil
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilwm
        xorg.xcbutil
        xorg.xcbutilcursor

        # GTK and dependencies (matching Dockerfile)
        gtk3
        gdk-pixbuf
        atk

        # Font and rendering
        fontconfig
        freetype
        harfbuzz
        libxslt

        # GStreamer (matching Dockerfile)
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-base

        # OpenSSL and crypto
        openssl
        nss

        # Cups
        cups

        # Other dependencies from Dockerfile
        dbus
        zlib
        bzip2
        readline
        sqlite
        unixODBC
        postgresql
        ncurses
        libpulseaudio
        expat
        glib
        gmp
        libpng

        # Build utilities
        autoconf
        automake
        libtool

        # For packaging (matching Dockerfile)
        fuse
        patchelf

        # linuxdeployqt (from Dockerfile)
        # Note: Using the version from CI
        (writeShellScriptBin "linuxdeployqt" ''
          # Download the same version used in CI
          LINUXDEPLOYQT_VERSION="20250615-0393b84"
          CACHE_DIR="$HOME/.cache/linuxdeployqt"
          LINUXDEPLOYQT="$CACHE_DIR/linuxdeployqt-$LINUXDEPLOYQT_VERSION-x86_64.AppImage"

          mkdir -p "$CACHE_DIR"

          if [ ! -f "$LINUXDEPLOYQT" ]; then
            echo "Downloading linuxdeployqt..."
            ${curl}/bin/curl -Lo "$LINUXDEPLOYQT" \
              "https://status-misc.ams3.digitaloceanspaces.com/desktop/linuxdeployqt-$LINUXDEPLOYQT_VERSION-x86_64.AppImage"
            chmod +x "$LINUXDEPLOYQT"
          fi

          exec "$LINUXDEPLOYQT" "$@"
        '')

        (writeShellScriptBin "appimagetool" ''
          # Download appimagetool
          CACHE_DIR="$HOME/.cache/appimagetool"
          APPIMAGETOOL="$CACHE_DIR/appimagetool-x86_64.AppImage"

          mkdir -p "$CACHE_DIR"

          if [ ! -f "$APPIMAGETOOL" ]; then
            echo "Downloading appimagetool..."
            ${wget}/bin/wget -nv -O "$APPIMAGETOOL" \
              https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
            chmod +x "$APPIMAGETOOL"
          fi

          exec "$APPIMAGETOOL" "$@"
        '')
      ];

      # Rust toolchain
      rustPlatform = pkgs.makeRustPlatform {
        cargo = pkgs.cargo;
        rustc = pkgs.rustc;
      };

    in {
      default = pkgs.mkShell {
        name = "status-desktop-dev";

        buildInputs = buildInputs ++ [ pkgs.rustc pkgs.cargo ];

        shellHook = ''
          echo "Status Desktop Development Environment"
          echo "======================================"
          echo ""
          echo "Qt version: $(qmake -query QT_VERSION)"
          echo "Go version: $(${go_1_24}/bin/go version)"
          echo "CMake version: $(${pkgs.cmake}/bin/cmake --version | head -n1)"
          echo "GCC version: $(${pkgs.gcc13}/bin/gcc --version | head -n1)"
          echo ""
          echo "Available make targets:"
          echo "  make update         - Update dependencies"
          echo "  make deps           - Build dependencies"
          echo "  make status-go      - Build status-go"
          echo "  make run            - Build and run Status Desktop"
          echo "  make pkg-linux      - Build AppImage package"
          echo ""

          # Set Qt environment
          export QTDIR="${pkgs.qt6.qtbase}"
          export QT_PLUGIN_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
          export QML2_IMPORT_PATH="${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtQmlPrefix}"

          # Set qmake spec
          export QMAKESPEC="linux-g++"

          # Disable Qt disk cache to avoid stale cache issues (from CI)
          export QML_DISABLE_DISK_CACHE=true

          # Set parallel build flags
          export MAKEFLAGS="-j$NIX_BUILD_CORES"

          # Set proper library paths for all dependencies
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"

          # Set locale (matching CI)
          export LANG=en_US.UTF-8
          export LANGUAGE=en_US:en
          export LC_ALL=en_US.UTF-8

          # Use GCC 13 (gcc11 removed from nixpkgs)
          export CC="${pkgs.gcc13}/bin/gcc"
          export CXX="${pkgs.gcc13}/bin/g++"

          echo "Environment configured:"
          echo "  QTDIR=$QTDIR"
          echo "  CC=$CC"
          echo "  CXX=$CXX"
          echo ""
        '';

        # Environment variables matching CI
        TERM = "xterm";
        QT_QPA_PLATFORM = "xcb";

        # For PCSC (matching CI setup)
        PCSCLITE_CFLAGS = "-I${pkgs.pcsclite.dev}/include/PCSC";
        PCSCLITE_LIBS = "-L${pkgs.pcsclite.out}/lib -lpcsclite";
      };
    });
  };
}
