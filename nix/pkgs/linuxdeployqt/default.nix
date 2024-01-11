{
  stdenv, fetchFromGitHub, qmake
}:

stdenv.mkDerivation rec {
  pname = "linuxdeployqt";
  version = "20230423-8428c59";
  commit = "8428c59318b250058e6cf93353e2871072bbf7f9";

  src = fetchFromGitHub {
    owner = "probonopd";
    repo = "linuxdeployqt";
    rev = commit;
    sha256 = "sha256-b1iWpWQRRSjmkNVuWTKRjzxmWGy4czteYNgFWb6Lofs=";
  };

  dontWrapQtApps = true;

  nativeBuildInputs = [
    qmake
  ];
}
