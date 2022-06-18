{stdenv, lib, fetchurl, jdk11_headless, makeWrapper, bash, curl, coreutils, gnugrep, unzip}:

stdenv.mkDerivation rec {
  version = "0.0.4";
  name = "meth-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/meth/releases/download/v${version}/meth-${version}";
     sha256 = "sha256-LjLUrA8ZKvNmyrTB/8D4Q42wxDroAtU31rucA4ttgJ0=";
   };

  buildInputs = [ jdk11_headless makeWrapper ];

  unpackPhase = "true";
  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp $src $out/program/meth-${version}
    makeWrapper ${jdk11_headless}/bin/java $out/bin/meth --add-flags "-jar $out/program/meth-${version}"
  '';

  meta = with lib; {
    description = "Commandline client for mediathekview.";
    homepage = https://github.com/eikek/meth;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
