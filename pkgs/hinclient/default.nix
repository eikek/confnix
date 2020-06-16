{ stdenv, fetchurl }:

stdenv.mkDerivation rec {

  version = "1.5.1-23";
  name = "hinclient-${version}";

  src = fetchurl {
    url = https://download.hin.ch/download/distribution/install/1.5.1-23/HINClient_unix_1_5_1-23.tar.gz;
    sha256 = "1f1kkpfmcyz3iw7rky8d6pj9lbqfb6hvabdljs59sd41pd9r9bcd";
  };

  buildPhase = "true";

  patchPhase = ''
    sed -i 's/hinclient.httpproxy.serverthreads=10/hinclient.httpproxy.serverthreads=100/g' hinclient.system.properties
    sed -i 's/hinclient.httpproxy.handlerthreads=10/hinclient.httpproxy.handlerthreads=100/g' hinclient.system.properties
  '';
  installPhase = ''
    mkdir -p $out
    mv * $out
    mv .install4j $out
  '';
}
