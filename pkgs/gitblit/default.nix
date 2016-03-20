{stdenv, fetchgit, jdk7, ant }:

stdenv.mkDerivation rec {
  version = "1.7.1";
  name = "gitblit-${version}";

  src = fetchgit {
    url = "https://github.com/gitblit/gitblit";
    rev = "refs/tags/v${version}";
    name = "gitblit-${version}-git";
    sha256 = "0wwffib2w2dw9h0sixx46kyqb1sq02q7wkrx36igicblqdh1djj3";
  };

  buildInputs = [ jdk7 ant ];

  patches = [
   ./httpauth.patch
   ./hardwraps.patch
  ];

  buildPhase = ''
    mkdir -p .m2 .moxie
    sed -i 's,''${user.home},$(pwd),g' build.xml
    HOME=$(pwd) ant buildGO
  '';

  installPhase = ''
    mkdir -p $out/
    tar xzf build/target/gitblit-${version}.tar.gz
    mv gitblit-${version}/* $out/ #*/
    sed -i s,/bin/bash,/bin/sh, $out/gitblit.sh
    sed -i s,java,${jdk7}/bin/java, $out/gitblit.sh
  '';

  meta = {
    description = "Gitblit is an open-source, pure Java stack for managing, viewing, and serving Git repositories.";
    homepage = http://gitblit.org/;
    license = stdenv.lib.licenses.asl20;
    maintainers = [ stdenv.lib.maintainers.eikek ];
  };
}
