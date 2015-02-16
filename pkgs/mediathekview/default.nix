{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "8.0";
  name = "mediathekview-${version}";

  src = fetchurl {
    url = http://downloads.sourceforge.net/project/zdfmediathk/Mediathek/Mediathek%208/MediathekView_8.zip;
    name = "${name}-download.zip";
    sha256 = "1sglzk8zh6cyijyw82k49yqzjv0ywglp03w09s7wr4mzk48mfjj9";
  };

  buildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/{program,bin}
    mv * $out/program/
    ln -sf $out/program/MediathekView__Linux.sh $out/bin/mediathekview
  '';

  meta = with stdenv.lib; {
    description = "MediathekView";
    homepage = http://sourceforge.net/projects/zdfmediathk/;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
