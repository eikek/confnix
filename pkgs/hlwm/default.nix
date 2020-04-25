{ stdenv, fetchurl, pkgconfig, glib, xorg, cmake, asciidoc-full, libxslt }:

stdenv.mkDerivation rec {
  name = "herbstluftwm-0.8.1";

  src = fetchurl {
    url = "https://herbstluftwm.org/tarballs/${name}.tar.gz";
    sha256 = "0c1lf82z6a56g8asin91cmqhzk3anw0xwc44b31bpjixadmns57y";
  };

  patchPhase = ''
    substituteInPlace CMakeLists.txt \
      --replace "/etc" "$out/share/etc"
  '';
  nativeBuildInputs = [ pkgconfig cmake ];
  buildInputs = [ glib
                  xorg.libX11
                  xorg.libXext
                  xorg.libXinerama
                  xorg.libXrandr
                  asciidoc-full
                  libxslt
                ];

  meta = {
    description = "A manual tiling window manager for X";
    homepage = http://herbstluftwm.org/;
    license = stdenv.lib.licenses.bsd2;
    platforms = stdenv.lib.platforms.linux;
  };
}
