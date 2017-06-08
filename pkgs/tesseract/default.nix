{ stdenv, fetchurl, autoconf, automake, libtool, leptonica, libpng, libtiff, giflib }:

with stdenv.lib;

let
  majVersion = "3.04";
  version = "${majVersion}.01";
  tessdata = let
    src = fetchurl {
      url = "https://github.com/tesseract-ocr/tessdata/archive/${majVersion}.00.tar.gz";
      sha256 = "1cddlyydl3ixwk4hymcd010inh7ibm9ywqdl8cw9bdinhcckgjsx";
    };
    in "tar xfvz ${src} -C $out/share/tessdata --strip 1";
in
stdenv.mkDerivation rec {
  name = "tesseract-${version}";

  src = fetchurl {
    url = "https://github.com/tesseract-ocr/tesseract/archive/${version}.tar.gz";
    sha256 = "0snwd8as5i8vx7zkimpd2yg898jl96zf90r65a9w615f2hdkxxjp";
  };

  buildInputs = [ autoconf automake libtool leptonica libpng libtiff giflib ];

  preConfigure = ''
      ./autogen.sh
      substituteInPlace "configure" \
        --replace 'LIBLEPT_HEADERSDIR="/usr/local/include /usr/include /opt/local/include/leptonica"' \
                  'LIBLEPT_HEADERSDIR=${leptonica}/include'
  '';

  postInstall = tessdata;

  meta = {
    description = "OCR engine";
    homepage = https://github.com/tesseract-ocr/tesseract;
    license = stdenv.lib.licenses.asl20;
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = with stdenv.lib.platforms; linux;
  };
}
