{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  version = "1.0.9";
  name = "roundcube-${version}";

  src = fetchurl {
    url = "https://github.com/roundcube/roundcubemail/releases/download/1.0.9/roundcubemail-1.0.9.tar.gz";
    sha256 = "1qk9fprzv7ycqa2mqsinkxj5h7fzfdgvwbbb6a2sac322hs550p4";
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
