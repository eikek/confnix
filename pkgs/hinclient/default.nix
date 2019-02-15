{ stdenv, fetchurl }:

stdenv.mkDerivation rec {

  version = "1.5.5-73";
  name = "hinclient-${version}";

  src = fetchurl {
    url = https://download.hin.ch/download/distribution/install/1.5.5-73/HINClient_unix_1_5_5-73.tar.gz;
    sha256 = "0l775a09bs4m2hdyjry7nra713vyavp1xjkzvhyamwziz9rvyyi8";
  };

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    mv * $out
    mv .install4j $out
  '';
}
