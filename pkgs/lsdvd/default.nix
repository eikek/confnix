{ stdenv, fetchurl, pkgconfig, libdvdread }:

stdenv.mkDerivation rec {
  name = "lsdvd-0.17";

  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/lsdvd/lsdvd/${name}.tar.gz";
    sha256 = "1274d54jgca1prx106iyir7200aflr70bnb1kawndlmcckcmnb3x";
  };

  buildInputs = [ pkgconfig libdvdread ];

  meta = {
    homepage = http://sourceforge.net/projects/lsdvd/;
    description = "A console application that displays the content of a dvd";
  };
}
