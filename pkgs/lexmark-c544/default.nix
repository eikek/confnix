{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  name = "lexmark-c544";

  src = fetchurl {
    url = https://www.openprinting.org/ppd-o-matic.php?driver=Postscript-Lexmark&printer=Lexmark-C544;
    name = "openprinting-c544.ppd";
    sha256 = "0mdqa9w1p6cmli6976v4wi0sw9r4p5prkj7lzfd1877wk11c9c73";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/cups/model/lexmark
    cp $src $out/share/cups/model/lexmark/c544.ppd
  '';
}
