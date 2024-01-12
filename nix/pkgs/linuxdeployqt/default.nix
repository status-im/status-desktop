{
  stdenv, fetchFromGitHub, qmake
}:

stdenv.mkDerivation rec {
  pname = "linuxdeployqt";
  version = "20230423-8428c59";
  commit = "2b38449ca9e9c68ad53e28531c017910ead6ebc4";

  src = fetchFromGitHub {
    owner = "probonopd";
    repo = "linuxdeployqt";
    rev = commit;
    #sha256 = "sha256-b1iWpWQRRSjmkNVuWTKRjzxmWGy4czteYNgFWb6Lofs=";
    sha256 = "sha256-2VIVYfYFhgDxaeSYwdsmoG/elf58SPLC1z2rEhde4rw=";
  };

  dontWrapQtApps = true;

  nativeBuildInputs = [
    qmake
  ];
}
