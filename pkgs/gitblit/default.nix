{stdenv, fetchgit, jdk, ant }:

stdenv.mkDerivation rec {
  version = "1.6.2";
  name = "gitblit-${version}";

  src = fetchgit {
    url = "https://github.com/gitblit/gitblit";
    #url = "http://dl.bintray.com/gitblit/releases/gitblit-${version}.tar.gz";
    rev = "refs/tags/v1.6.2";
    name = "gitblit-${version}-git";
    sha256 = "18j03gfa7v4cn97z189wmm8c6n2f8dri7xq4ggjs36kypimkwh54";
  };

  buildInputs = [ jdk ant ];

  patches = [
   ./httpauth.patch
  ];

  buildPhase = ''
    mkdir -p .m2 .moxie
    sed -i 's,''${user.home},$(pwd),g' build.xml
    HOME=$(pwd) ant buildGO
  '';

  installPhase = ''
    mkdir -p $out/
    tar xzf build/target/gitblit-${version}.tar.gz -C $out/
    sed -i s,/bin/bash,/bin/sh, $out/gitblit.sh
    sed -i s,java,${jdk}/bin/java, $out/gitblit.sh
  '';

  meta = {
    description = "Gitblit is an open-source, pure Java stack for managing, viewing, and serving Git repositories.";
    homepage = http://gitblit.org/;
    license = stdenv.lib.licenses.asl20;
    maintainers = [ stdenv.lib.maintainers.eikek ];
  };
}