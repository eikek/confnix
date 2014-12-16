{stdenv, fetchgit, sbt, git}:

stdenv.mkDerivation rec {
  version = "0.3.0-20141216";
  name = "sitebag-${version}";

  src = fetchgit {
    url = https://github.com/eikek/sitebag;
    rev = "refs/heads/master";

    # buildinfo plugin reads the current commit on build
    # thus, need to build from git sources
    leaveDotGit = true;
    name = "sitebag-${version}-git";
    sha256 = "009b7alh8h2xy4k6jwil9d4vfjyx688aw04cvwh6sdsgd2d6wcsi";
  };

  buildInputs = [ sbt git ];

  patchPhase = ''
    sed -i 's,version := "0.3.0-SNAPSHOT",version := "${version}",' project/Sitebag.scala
  '';

  buildPhase = ''
    mkdir -p _sbt/{boot,ivy2}
    export SBT_OPTS="-XX:PermSize=190m -Dsbt.boot.directory=_sbt/boot/ -Dsbt.ivy.home=_sbt/ivy2/"
    ${sbt}/bin/sbt clean dist
  '';

  installPhase = ''
    mkdir -p $out/
    cp -R target/sitebag-${version}/* $out/
    chmod +x $out/bin/start-sitebag.sh
  '';
  /**/

  meta = with stdenv.lib; {
    description = "A web application that allows to store web sites for later reading.";
    homepage = https://github.com/eikek/sitebag;
    license = licenses.asl20;
    maintainers = [ maintainers.eikek ];
  };
}
