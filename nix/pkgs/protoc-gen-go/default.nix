{ pkgs ? import <nixpkgs> { } }:

let 
  inherit (pkgs) lib buildGo121Module fetchFromGitHub;
in buildGo121Module rec {
  pname = "protoc-gen-go";
  version = "1.34.1";

  src = fetchFromGitHub {
    owner = "protocolbuffers";
    repo = "protobuf-go";
    rev = "v${version}";
    sha256 = "sha256-xbfqN/t6q5dFpg1CkxwxAQkUs8obfckMDqytYzuDwF4=";
  };

  vendorHash = "sha256-nGI/Bd6eMEoY0sBwWEtyhFowHVvwLKjbT4yfzFz6Z3E=";

  subPackages = [ "cmd/protoc-gen-go" ];

  meta = with lib; {
    description = "Go support for Google's protocol buffers";
    mainProgram = "protoc-gen-go";
    homepage = "https://google.golang.org/protobuf";
    license = licenses.bsd3;
    maintainers = with lib.maintainers; [ jojosch ];
  };
}
