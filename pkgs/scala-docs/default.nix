{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "2.11.7";
  name = "scala-docs-${version}";

  src = fetchurl {
    url = "http://downloads.typesafe.com/scala/${version}/${name}.zip";
    sha256 = "0rwn927jggmqyi2gz5vyw0p37ghk3jcqy73n0z76a92mi3rip64h";
  };

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
