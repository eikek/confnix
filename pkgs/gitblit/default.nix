{stdenv, fetchurl, jdk}:

stdenv.mkDerivation rec {
  version = "1.6.2";
  name = "gitblit-${version}";

  src = fetchurl {
    url = "http://dl.bintray.com/gitblit/releases/gitblit-${version}.tar.gz";
    sha256 = "02blfjalv5fhbbrl736r9lr3wg4sq19xyrhyv337fl13sqam377b";
  };

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    mkdir -p $out/
    cp -R * $out/
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
