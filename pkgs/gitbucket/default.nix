{stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation rec {
  version = "4.10";
  name = "gitbucket-${version}";

  src = fetchurl {
    url = "https://github.com/gitbucket/gitbucket/releases/download/${version}/gitbucket.war";
    name = "gitbucket-${version}.war";
    sha256 = "18y11l83d9h3snaw8a97dl4y1gwcr7ljcp54kg21x4ig41gkrzyq";
  };

  unpackPhase = "true";

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp $src $out/program/gitbucket.war
    makeWrapper ${jre}/bin/java $out/bin/gitbucket --add-flags "-jar $out/program/gitbucket.war"
  '';

  meta = {
    description = ''
      A Git platform powered by Scala with easy installation, high
      extensibility & github API compatibility
    '';
    homepage = https://gitbucket.github.io/gitbucket-news/;
    license = stdenv.lib.licenses.asl20;
  };
}
