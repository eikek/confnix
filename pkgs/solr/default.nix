{lib, stdenv, fetchurl, makeWrapper, jre }:
# https://discourse.nixos.org/t/solr-has-been-removed-what-are-my-options/33504/3
stdenv.mkDerivation rec {
  pname = "solr";
  version = "9.4.1";

  src = fetchurl {
    url = "mirror://apache/solr/${pname}/${version}/${pname}-${version}-slim.tgz";
    sha256 = "sha256-+nxsIxYM3PapkFGMY9zIANvx3wovw8U4jToVIWcsQ6k=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
      mkdir -p $out $out/bin

      cp -r bin/solr bin/post $out/bin/
      cp -r docs $out/
      cp -r example $out/
      cp -r server $out/

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
