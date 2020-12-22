{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  name = "lexmark-mc2425";

  src = fetchurl {
    url = https://openprinting.org/ppd-o-matic.php?driver=Postscript-Lexmark&printer=Lexmark-MC2425adw;
    name = "openprinting-mc2425.ppd";
    sha256 = "1vc21r6prj3cam94gbc7ggq1mmhix0ndnfn6ijyhhw5bzv896a5s";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/cups/model/lexmark
    cp $src $out/share/cups/model/lexmark/mc2425.ppd
  '';
}
