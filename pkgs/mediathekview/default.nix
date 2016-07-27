{stdenv, fetchurl, unzip}:

stdenv.mkDerivation rec {
  version = "11";
  name = "mediathekview-${version}";

  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/zdfmediathk/Mediathek/Mediathek%20${version}/MediathekView_${version}.zip";
    name = "${name}-download.zip";
    sha256 = "1gyb9jfd2yxkf4gknwvd792idpkim63kbqylq7qs17mjvkif4ihq";
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
