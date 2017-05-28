{stdenv, fetchurl, jre }:

stdenv.mkDerivation rec {
  version = "0.2.0-SNAPSHOT";
  name = "sharry-${version}";
  src = fetchurl {
    url = "https://eknet.org/main/projects/sharry/sharry-server-${version}.jar.sh";
    sha256 = "072gb14s51z7i2wgf3x9qwzahlrx2p0s52w3blfks5ym6wfw1wms";
  };

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp $src $out/program/sharry-server
    chmod 755 $out/program/sharry-server

    cat > $out/bin/sharry-server <<-EOF
    #!/usr/bin/env bash
    export PATH=${jre}/bin:$PATH
    $out/program/sharry-server "\$@"
    EOF
    chmod 755 $out/bin/sharry-server
  '';

  meta = {
    description = "Sharry allows to share files with others in a simple way. It is a self-hosted web application.";
    license = stdenv.lib.licenses.gpl3;
    homepage = https://github.com/eikek/sharry;
  };
}
