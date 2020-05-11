{stdenv, fetchurl, jre8_headless, makeWrapper, bash, curl, coreutils, gnugrep, unzip}:

stdenv.mkDerivation rec {
  version = "0.0.3";
  name = "meth-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/meth/releases/download/v${version}/meth-${version}";
     sha256 = "0qd26i33hm59rc6x3gbgpyq85pgf3n6dwpqc2sppa8wpgj3v92jh";
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
