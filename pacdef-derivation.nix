{ stdenv, fetchurl, lib }:

stdenv.mkDerivation rec {
  pname = "pacdef";
  version = "1.6.0";

  src = fetchurl {
    url =
      "https://github.com/steven-omaha/pacdef/releases/download/v${version}/pacdef-debian.tar.gz";
    sha256 = "3fdeba6ec9c146addfe6792f0d6732729020492aff8a263625bd9dc4a1b729a3";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp pacdef $out/bin/
  '';

  meta = {
    description =
      "multi-backend declarative package manager for Linux";
    homepage = "https://github.com/steven-omaha/pacdef";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.StevenBuglione ];
    mainProgram = "pacdef";
  };
}
