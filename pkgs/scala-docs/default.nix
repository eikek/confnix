{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "2.11.5";
  name = "scala-docs-${version}";

  src = fetchurl {
    url = "http://downloads.typesafe.com/scala/${version}/${name}.zip";
    sha256 = "0qlq7441g2fj419b0marp74prh4kyf7fnl7xhs73f898f5r4bvzm";
  };

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
