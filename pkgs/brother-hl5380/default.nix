{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  name = "brother-hl5380";

  src = fetchurl {
    url = https://www.openprinting.org/ppd-o-matic.php?driver=Postscript-Brother&printer=Brother-HL-5380DN&show=0;
    name = "openprinting-brother-hl5380.ppd";
    sha256 = "0vy0sndwgk4y00ig64yw8khxzwahxa98qgjigmnfxwdxdlxq9s9b";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/cups/model/brother
    cp $src $out/share/cups/model/brother/hl5380.ppd
  '';
}
