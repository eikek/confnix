{stdenv, fetchgit, sbt, git}:

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

  buildInputs = [ sbt git ];

  buildPhase = ''
    mkdir -p _sbt/{boot,ivy2}
    echo "sbt.version=0.12.4" > project/build.properties
    export SBT_OPTS="-XX:PermSize=190m -Dsbt.boot.directory=_sbt/boot/ -Dsbt.ivy.home=_sbt/ivy2/"
    ${sbt}/bin/sbt clean assembly
  '';

  installPhase = ''
    mkdir -p $out/
    cp target/publet-sharry-assembly-0.2.0-SNAPSHOT.jar $out/publet-sharry.jar
  '';
  /**/

  meta = with stdenv.lib; {
    description = "Sharry is an extension for publet that allows to share files with others in a simple way.";
    homepage = https://github.com/eikek/publet-sharry;
    license = licenses.asl20;
    maintainers = [ maintainers.eikek ];
  };
}
