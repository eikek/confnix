{stdenv, fetchgit, sbt, git}:

stdenv.mkDerivation rec {
  version = "1.2.1-20130612";
  name = "publet-${version}";

  src = fetchgit {
    url = https://github.com/eikek/publet;
    rev = "refs/heads/1.x";

    # buildinfo plugin reads the current commit on build
    # thus, need to build from git sources
    leaveDotGit = true;
    name = "publet-${version}-git";
    sha256 = "1wgrkpahhcniipx1ykdqy447x3y05hr95wg5sd03im8wpz6fvqa9";
  };

  buildInputs = [ sbt git ];

  buildPhase = ''
    mkdir -p _sbt/{boot,ivy2}
    echo "sbt.version=0.12.4" > project/build.properties
    export SBT_OPTS="-XX:PermSize=190m -Dsbt.boot.directory=_sbt/boot/ -Dsbt.ivy.home=_sbt/ivy2/"
    ${sbt}/bin/sbt clean server-dist
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
