{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "lume";
  version = "0.1.9";

  src = fetchurl {
    url = "https://github.com/trycua/lume/releases/download/v${version}/lume.tar.gz";
    sha256 = "824eee499d7101bfe6327dd4534fc43189807f1b2d8edee96824400c35aab192";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp lume $out/bin/
    chmod +x $out/bin/lume
  '';

  meta = with lib; {
    description = "CLI and local API server to run macOS and Linux VMs on Apple Silicon";
    homepage = "https://github.com/trycua/lume";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}
