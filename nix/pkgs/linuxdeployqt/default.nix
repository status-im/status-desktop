{
  stdenv, fetchFromGitHub, qmake
}:

stdenv.mkDerivation rec {
  pname = "linuxdeployqt";
  version = "20231227-2b38489";
  commit = "2b38449ca9e9c68ad53e28531c017910ead6ebc4";

  src = fetchFromGitHub {
    owner = "probonopd";
    repo = "linuxdeployqt";
    rev = commit;
    sha256 = "sha256-2VIVYfYFhgDxaeSYwdsmoG/elf58SPLC1z2rEhde4rw=";
  };

  dontWrapQtApps = true;

  nativeBuildInputs = [
    qmake
  ];
}
