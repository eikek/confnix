{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "2.11.6";
  name = "scala-docs-${version}";

  src = fetchurl {
    url = "http://downloads.typesafe.com/scala/${version}/${name}.zip";
    sha256 = "0m12nvw9lf4yb1crpv22mcx3igih9ml2n5jvv0nd6l0frhhv2zxa";
  };

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
