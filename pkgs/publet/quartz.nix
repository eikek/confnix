{stdenv, fetchurl, fetchgit, jdk, git}:
let
  sbtVersion = "0.12.4";
in
stdenv.mkDerivation rec {
  version = "0.2.0-SNAPSHOT-20121220";
  name = "publet-quartz-${version}";

  src = fetchgit {
    url = https://git.eknet.org/r/~eike/attic/publet-quartz.git;
    rev = "refs/heads/master";

    # buildinfo plugin reads the current commit on build
    # thus, need to build from git sources
    leaveDotGit = true;
    name = "publet-quartz-${version}-git";
    sha256 = "0b7j2c84ad4cy7bnrlqm4ainykprkz9rskirr91fqpyzbh1ng59r";
  };

  buildInputs = [ jdk git ];

  assembly = ./sbt-assembly-0.9.2.jar;

  sbt = fetchurl {
    url = "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${sbtVersion}/sbt-launch.jar";
    sha256 = "04k411gcrq35ayd2xj79bcshczslyqkicwvhkf07hkyr4j3blxda";
  };

  patchPhase = ''
    sed -i '$ d' project/build.sbt
    echo "sbt.version=0.12.4" > project/build.properties
    patch -p0 < ${./quartz-resolver.patch}
    mkdir -p project/lib
    cp ${assembly} project/lib/sbt-assembly-0.9.2.jar
  '';

  buildPhase = ''
    mkdir -p _sbt/{boot,ivy2}
    export SBT_OPTS="-XX:PermSize=190m -Dsbt.boot.directory=_sbt/boot/ -Dsbt.ivy.home=_sbt/ivy2/ -Dsbt.global.base=_sbt/"
    ${jdk}/bin/java $SBT_OPTS -jar ${sbt} assembly
  '';

  installPhase = ''
    mkdir -p $out/
    cp target/scala-2.9.2/publet-quartz-assembly-0.2.0-SNAPSHOT.jar $out/publet-quartz.jar
  '';

  meta = with stdenv.lib; {
    description = "Quartz is an extension for publet that integrates the quartz library.";
    homepage = https://git.eknet.org/summary/~eike%2Fattic%2Fpublet-quartz.git;
    license = licenses.asl20;
    maintainers = [ maintainers.eikek ];
  };
}
