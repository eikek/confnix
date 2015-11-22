{stdenv, fetchurl, fetchgit, jdk, git}:
let
  sbtVersion = "0.12.4";
in
stdenv.mkDerivation rec {
  version = "0.2.0-SNAPSHOT-20130620";
  name = "publet-sharry-${version}";

  src = fetchgit {
    url = https://github.com/eikek/publet-sharry;
    rev = "refs/heads/master";

    # buildinfo plugin reads the current commit on build
    # thus, need to build from git sources
    leaveDotGit = true;
    name = "publet-sharry-${version}-git";
    sha256 = "09ap0g7i1n4qb27a69x1z9y1sc01xfag868qzibiv43jq0bzcmas";
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
    cp target/scala-2.9.2/publet-sharry-assembly-0.2.0-SNAPSHOT.jar $out/publet-sharry.jar
  '';

  meta = with stdenv.lib; {
    description = "Sharry is an extension for publet that allows to share files with others in a simple way.";
    homepage = https://github.com/eikek/publet-sharry;
    license = licenses.asl20;
    maintainers = [ maintainers.eikek ];
  };
}
