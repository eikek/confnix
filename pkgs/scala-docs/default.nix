{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "2.12.4";
  name = "scala-docs-${version}";

  src = fetchurl {
    url = "http://downloads.typesafe.com/scala/${version}/${name}.zip";
    sha256 = "19d2nnanh1s7dng8fxy21p09wgchhz2giw3d7s2jmnv9as2pkggz";
  };

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
