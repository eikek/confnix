{ stdenv, fetchurl }:

stdenv.mkDerivation rec {

  version = "1.5.3-50";
  name = "hinclient-${version}";

  src = fetchurl {
    url = "https://download.hin.ch/download/distribution/install/${version}/HINClient_unix_1_5_3-50.tar.gz";
    sha256 = "0s8chs1kgfi1zswylkx39vm30qzrvkglr2gr4hrlphazf0z8jzsb";
  };

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    mv * $out
    mv .install4j $out
  '';
}
