{stdenv, fetchgit, fetchurl, git, jdk}:

let
  sbtVersion = "0.12.4";
in
stdenv.mkDerivation rec {
  version = "1.2.1-20130612";
  name = "publet-${version}";

  src = fetchgit {
    url = https://github.com/eikek/publet;
    rev = "635f8a4cee06d50589696de02368cc5194f34c47";

    # buildinfo plugin reads the current commit on build
    # thus, need to build from git sources
    leaveDotGit = true;
    name = "publet-${version}-git";
    sha256 = "0bw7yb1189vsxsc4f24z8kid4zw7pjklcfx33qmqhva192j99107";
  };

  assembly = ./sbt-assembly-0.9.2.jar;

  sbt = fetchurl {
    url = "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${sbtVersion}/sbt-launch.jar";
    sha256 = "04k411gcrq35ayd2xj79bcshczslyqkicwvhkf07hkyr4j3blxda";
  };

  buildInputs = [ git jdk ];

  patchPhase = ''
    mkdir -p _sbt/{boot,ivy2}
    rm project/project/build.scala
    mkdir -p project/lib
    cp ${assembly} project/lib/sbt-assembly-0.9.2.jar
    patch -p0 < ${./resolve.patch}
  '';

  buildPhase = ''
    export SBT_OPTS="-XX:PermSize=190m -Dsbt.boot.directory=_sbt/boot/ -Dsbt.ivy.home=_sbt/ivy2/ -Dsbt.global.base=_sbt/"
    ${jdk}/bin/java $SBT_OPTS -jar ${sbt} server-dist
  '';

  installPhase = ''
    mkdir -p $out/
    cp -R server/target/publet-server-1.2.1-SNAPSHOT/* $out/
  '';
  /**/

  meta = with stdenv.lib; {
    description = "Template web application.";
    homepage = https://github.com/eikek/publet;
    license = licenses.asl20;
    maintainers = [ maintainers.eikek ];
  };
}
