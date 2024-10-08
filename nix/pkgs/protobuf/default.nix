{ lib, stdenv, fetchFromGitHub, autoreconfHook, zlib, gtest, buildPackages }:

stdenv.mkDerivation rec {
  pname = "protobuf";
  version = "3.20.3";

  # make sure you test also -A pythonPackages.protobuf
  src = fetchFromGitHub {
    owner = "protocolbuffers";
    repo = "protobuf";
    rev = "v${version}";
    sha256 = "sha256-u/1Yb8+mnDzc3OwirpGESuhjkuKPgqDAvlgo3uuzbbk=";
  };

  postPatch = ''
    rm -rf gmock
    cp -r ${gtest.src}/googlemock gmock
    cp -r ${gtest.src}/googletest googletest
    chmod -R a+w gmock
    chmod -R a+w googletest
    ln -s ../googletest gmock/gtest
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/google/protobuf/testing/googletest.cc \
      --replace 'tmpnam(b)' '"'$TMPDIR'/foo"'
  '';

  nativeBuildInputs = [ autoreconfHook buildPackages.which buildPackages.stdenv.cc ];

  buildInputs = [ zlib ];

  enableParallelBuilding = true;

  doCheck = true;

  dontDisableStatic = true;

  meta = {
    description = "Google's data interchange format";
    longDescription =
      ''Protocol Buffers are a way of encoding structured data in an efficient
        yet extensible format. Google uses Protocol Buffers for almost all of
        its internal RPC protocols and file formats.
      '';
    homepage = "https://developers.google.com/protocol-buffers/";
    license = lib.licenses.bsd3;
    mainProgram = "protoc";
    platforms = lib.platforms.unix;
  };
}
