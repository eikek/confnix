{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  version = "1.2.0";
  name = "roundcube-${version}";

  src = fetchurl {
    url = "https://github.com/roundcube/roundcubemail/releases/download/${version}/roundcubemail-${version}-complete.tar.gz";
    sha256 = "1k2l535nidq54jvlgfml4y9llwxbq3h7hfl4y3m7ibdm0gd9aj2p";
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
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = [ stdenv.lib.maintainers.eikek ];
  };
}
