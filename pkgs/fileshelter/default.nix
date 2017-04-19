{stdenv, fetchurl, wt, automake, autoconf, boost, libconfig, libzip }:

stdenv.mkDerivation rec {
  version = "2.0.1";
  name = "fileshelter-${version}";
  src = fetchurl {
    url = "https://github.com/epoupon/fileshelter/archive/v${version}.tar.gz";
    sha256 = "1qnrb7w9423cj6wv66arjk19ik45s4a367iwp6sx846k4gcmvck1";
  };

  buildInputs = [ wt automake autoconf boost libconfig libzip ];

  patchPhase = ''
     sed -i s,/usr/share/Wt/resources,${wt}/share/Wt/resources,g Makefile.am
  '';

  preConfigure = ''
    autoreconf -vfi
  '';

  meta = {
    description = "FileShelter is a “one-click” file sharing web application";
    license = stdenv.lib.licenses.gpl3;
    homepage = https://github.com/epoupon/fileshelter;
  };
}
