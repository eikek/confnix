{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  version = "2.15.2";
  name = "blueimp-gallery-${version}";

  src = fetchurl {
    url = "https://github.com/blueimp/Gallery/archive/${version}.tar.gz";
    name = "blueimp-gallery-${version}-src.tar.gz";
    sha256 = "0p67grp3s0i5j4d22z60qgi22qrcjgkx6v69vlhgz3ks291arnzq";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  ''; #*/

  meta = with stdenv.lib; {
    description = "Blueimp Gallery";
    homepage = https://github.com/blueimp/Gallery;
    license = licenses.mit;
    maintainers = [ maintainers.eikek ];
  };
}
