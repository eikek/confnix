{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "3.1.1";
  name = "blueimp-image-gallery-${version}";

  src = fetchurl {
    url = "https://github.com/blueimp/Bootstrap-Image-Gallery/archive/${version}.zip";
    name = "blueimp-bootstrap-image-gallery-${version}-src.zip";
    sha256 = "05bdi2rvwqrs101cjybjwsw7f8if8af37zhid5lr1vn9h5b5l0g1";
  };

  buildInputs = [ unzip ];

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
