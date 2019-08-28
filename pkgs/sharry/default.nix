{ stdenv, fetchurl, jre8_headless }:

stdenv.mkDerivation rec {
  version = "0.6.1";
  name = "sharry-${version}";
  src = fetchurl {
    url = "https://github.com/eikek/sharry/releases/download/release%2F${version}/sharry-server-${version}.jar.sh";
    sha256 = "1axcspyvpw5qwifvwg8jf1dcx5c8hqx706p0pspb8s3gsjvlahnx";
  };

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp $src $out/program/sharry-server
    chmod 755 $out/program/sharry-server

    cat > $out/bin/sharry-server <<-EOF
    #!/usr/bin/env bash
    export PATH=${jre8_headless}/bin:$PATH
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
