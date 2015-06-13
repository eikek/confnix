{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  version = "3.1.1";
  name = "blueimp-image-gallery-${version}";

  src = fetchurl {
    url = "https://github.com/blueimp/Bootstrap-Image-Gallery/archive/${version}.tar.gz";
    name = "blueimp-bootstrap-image-gallery-${version}-src.tar.gz";
    sha256 = "0q82f5452924ckgchnq1v9wz9rlh9ywri6qvwi4gk4zs1bfrikv3";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  ''; #*/

  meta = with stdenv.lib; {
    description = "Blueimp's Bootstrap Image Gallery";
    homepage = https://github.com/blueimp/Bootstrap-Image-Gallery;
    license = licenses.mit;
    maintainers = [ maintainers.eikek ];
  };
}
