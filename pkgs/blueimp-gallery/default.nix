{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "2.15.2";
  name = "blueimp-gallery-${version}";

  src = fetchurl {
    url = "https://github.com/blueimp/Gallery/archive/${version}.zip";
    sha256 = "0idkm903vpyjrscap8q5c2zx8r1l0xgkpvgnxzm3grrkqasijpcs";
  };

  buildInputs = [ unzip ];

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
