{stdenv, fetchgit, sbt, git}:

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

  buildInputs = [ sbt git ];

  buildPhase = ''
    mkdir -p _sbt/{boot,ivy2}
    echo "sbt.version=0.12.4" > project/build.properties
    patch -p0 < ${./quartz-resolver.patch}
    export SBT_OPTS="-XX:PermSize=190m -Dsbt.boot.directory=_sbt/boot/ -Dsbt.ivy.home=_sbt/ivy2/"
    ${sbt}/bin/sbt clean assembly
  '';

  installPhase = ''
    mkdir -p $out/
    cp target/publet-quartz-assembly-0.2.0-SNAPSHOT.jar $out/publet-quartz.jar
  '';

  meta = with stdenv.lib; {
    description = "Quartz is an extension for publet that allows to share files with others in a simple way.";
    homepage = https://git.eknet.org/summary/~eike%2Fattic%2Fpublet-quartz.git;
    license = licenses.asl20;
    maintainers = [ maintainers.eikek ];
  };
}
