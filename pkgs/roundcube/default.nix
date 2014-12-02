{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  version = "1.0.3";
  name = "roundcube-${version}";

  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/roundcubemail/roundcubemail/${version}/roundcubemail-${version}.tar.gz";
    sha256 = "1jm9z4waaw9zfl9mvdlcmsdx2wbp1zafixfz6pmmxlq83dnbnh48";
  };

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    mkdir -p $out/roundcube
    cp -R roundcubemail-${version}/* $out/roundcube/
  '';
  /**/

  meta = {
    description = ''
       Roundcube webmail is a browser-based multilingual IMAP
       client with an application-like user interface.
    '';
    homepage = http://roundcube.net/;
    license = stdenv.lib.licenses.gpl3plus;
    maintainers = [ stdenv.lib.maintainers.eikek ];
  };
}
