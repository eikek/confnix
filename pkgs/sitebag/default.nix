{stdenv, fetchgit, sbt, git}:

stdenv.mkDerivation rec {
  version = "0.2.0";
  name = "sitebag-${version}";

  src = fetchgit {
    url = https://github.com/eikek/sitebag;
    rev = "refs/tags/releases/0.2.0";

    # buildinfo plugin reads the current commit on build
    # thus, need to build from git sources
    leaveDotGit = true;
    name = "sitebag-${version}";
    sha256 = "035400fhjnfkpspaiwzm96g79wf0daqbybnahp4r5b8gx2i6cbbl";
  };

  buildInputs = [ sbt git ];

  buildPhase = ''
    mkdir -p _sbt/{boot,ivy2}
    export SBT_OPTS="-XX:PermSize=190m -Dsbt.boot.directory=_sbt/boot/ -Dsbt.ivy.home=_sbt/ivy2/"
    ${sbt}/bin/sbt clean dist
  '';

  installPhase = ''
    mkdir -p $out/
    cp -R target/sitebag-${version}/* $out/
  '';
  /**/

  fixupPhase = ''
    rm $out/bin/start.sh
    cp ${./start.sh} $out/bin/start-sitebag.sh
    chmod +x $out/bin/start-sitebag.sh
  '';

  meta = {
    description = "A web application that allows to store web sites for later reading.";
    homepage = https://github.com/eikek/sitebag;
    license = "ASF";
    maintainers = [ stdenv.lib.maintainers.eikek ];
  };
}
