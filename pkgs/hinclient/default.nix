{ stdenv, fetchurl }:

stdenv.mkDerivation rec {

  version = "1.5.1-23";
  name = "hinclient-${version}";

  src = fetchurl {
    url = https://download.hin.ch/download/distribution/install/1.5.1-23/HINClient_unix_1_5_1-23.tar.gz;
    sha256 = "1f1kkpfmcyz3iw7rky8d6pj9lbqfb6hvabdljs59sd41pd9r9bcd";
  };

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    mv * $out
    mv .install4j $out
  '';
}
