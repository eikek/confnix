{stdenv, fetchurl, jre8_headless, makeWrapper, bash, curl, coreutils, gnugrep, unzip}:

stdenv.mkDerivation rec {
  version = "0.0.2";
  name = "meth-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/meth/releases/download/v${version}/meth-${version}";
     sha256 = "0px1x61ywdyiryzgkfwapcld19ys94n500lrfwxl1rlmms65pl3y";
   };

  buildInputs = [ jre8_headless makeWrapper ];

  unpackPhase = "true";
  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp $src $out/program/meth-${version}
    makeWrapper ${jre8_headless}/bin/java $out/bin/meth --add-flags "-jar $out/program/meth-${version}"
  '';

  meta = with stdenv.lib; {
    description = "Commandline client for mediathekview.";
    homepage = https://github.com/eikek/meth;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
