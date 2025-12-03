{
  description = "Fastlane environment for iOS signing";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Pin Ruby 3.1 for fastlane
        ruby = pkgs.ruby_3_1;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            ruby
            pkgs.git
            pkgs.openssh
            pkgs.openssl
            pkgs.cacert
            pkgs.curl
            pkgs.pkg-config
            pkgs.libyaml
          ];

          shellHook = ''
            export GEM_HOME="$PWD/.gems"
            export GEM_PATH="$GEM_HOME"
            export PATH="$GEM_HOME/bin:$PATH"
            export LANG="en_US.UTF-8"

            export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            export CURL_CA_BUNDLE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

            unset BUNDLE_PATH
            unset BUNDLE_GEMFILE

            echo "Ruby $(ruby --version)"
            echo "Bundler $(bundle --version)"
            echo ""
            echo "Run 'bundle install' to install fastlane dependencies"
          '';
        };
      }
    );
}
