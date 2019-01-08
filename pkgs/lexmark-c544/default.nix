{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  name = "lexmark-c544";

  src = fetchurl {
    url = https://www.openprinting.org/ppd-o-matic.php?driver=Postscript-Lexmark&printer=Lexmark-C544;
    name = "openprinting-c544.ppd";
    sha256 = "08mjg7p53ifl8is2vhqgvpnishadk4mhw9pln99aip2fcnzkzwx8";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/cups/model/lexmark
    cp $src $out/share/cups/model/lexmark/c544.ppd
  '';
}
