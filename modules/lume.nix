{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  pkgs,
}:

stdenv.mkDerivation rec {
  pname = "lume";
  version = "0.1.9";

  src = fetchurl {
    url = "https://github.com/trycua/lume/releases/download/v${version}/lume.pkg.tar.gz";
    sha256 = "sha256-OokLJfjDehuAeESIm+mQiUd5VhHi7iprFeE8tPGr9WQ=";
  };

  nativeBuildInputs = [
    (pkgs).gnutar # for tar
    (pkgs).cpio # for cpio
    (pkgs).gzip
    # (pkgs).darwin.pkgutil
  ];

  # We’ll extract the .pkg and then the payload inside it
  unpackPhase = ''
    # Unpack the tarball -> yields lume.pkg
    tar xvf $src

    # Expand the .pkg into a directory named pkg-expanded
    /usr/sbin/pkgutil --expand lume.pkg pkg-expanded

    # Inside pkg-expanded, there's a "Payload" file (cpio + gzip).
    cd pkg-expanded
    cat Payload | gzip -d | cpio -id
  '';

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    /usr/sbin/installer -pkg lume.pkg -target $out
    # You might need to create proper symlinks after this
    mkdir -p $out/bin
    ln -s $out/usr/local/bin/lume $out/bin/lume
  '';

  meta = with lib; {
    description = "CLI and local API server to run macOS and Linux VMs on Apple Silicon";
    homepage = "https://github.com/trycua/lume";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}
