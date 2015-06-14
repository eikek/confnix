{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "9.0";
  name = "mediathekview-${version}";

  src = fetchurl {
    url = http://downloads.sourceforge.net/project/zdfmediathk/Mediathek/Mediathek%209/MediathekView_9.zip;
    name = "${name}-download.zip";
    sha256 = "1wff0igr33z9p1mjw7yvb6658smdwnp22dv8klz0y8qg116wx7a4";
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
