{ lib, stdenv, fetchurl, version, hashes, autoPatchelfHook }:
let
  toGoKernel = platform:
    if platform.isDarwin then "darwin"
    else platform.parsed.kernel.name;

  goarch = platform: {
    "aarch64" = "arm64";
    "arm"     = "arm";
    "armv6l"  = "arm";
    "armv7l"  = "arm";
    "x86_64"  = "amd64";
  }.${platform.parsed.cpu.name} or (throw "Unsupported system: ${platform.parsed.cpu.name}");

  toGoPlatform = platform: "${toGoKernel platform}-${goarch platform}";

  platform = toGoPlatform stdenv.hostPlatform;
in
stdenv.mkDerivation rec {
  name = "go-${version}-${platform}-bootstrap";

  src = fetchurl {
    url = "https://go.dev/dl/go${version}.${platform}.tar.gz";
    sha256 = hashes.${platform} or (throw "Missing Go bootstrap hash for platform ${platform}");
  };

  #nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  # We must preserve the signature on Darwin
  dontStrip = stdenv.hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/go $out/bin
    cp -r . $out/share/go
    ln -s $out/share/go/bin/go $out/bin/go
    runHook postInstall
  '';

  GOOS = stdenv.targetPlatform.parsed.kernel.name;
  GOARCH = goarch stdenv.targetPlatform;
}
