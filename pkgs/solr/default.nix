{lib, stdenv, fetchurl, makeWrapper, jre }:
# https://discourse.nixos.org/t/solr-has-been-removed-what-are-my-options/33504/3
stdenv.mkDerivation rec {
  pname = "solr";
  version = "9.4.1";

  src = fetchurl {
    url = "mirror://apache/solr/${pname}/${version}/${pname}-${version}.tgz";
    sha256 = "sha256-QQFdemk/76S4pTf10Jgq2ujxPzgu3znJSjSX+bN4MlA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
    rm -rf $out/bin/init.d
    rm $out/bin/postlogs
    rm $out/bin/install_solr_service.sh
    rm $out/bin/solr.in.sh
    rm $out/bin/*.cmd

    wrapProgram $out/bin/solr --set JAVA_HOME "${jre}"
    wrapProgram $out/bin/post --set JAVA_HOME "${jre}"
  '';

  meta = with lib; {
    homepage = "https://lucene.apache.org/solr/";
    description = "Open source enterprise search platform from the Apache Lucene project";
    license = licenses.asl20;
    latforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
