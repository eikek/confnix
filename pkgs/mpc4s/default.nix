{stdenv, lib, fetchurl, jre8, unzip, bash}:

stdenv.mkDerivation rec {
  version = "0.3.2";
  name = "mpc4s-player-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/mpc4s/releases/download/v${version}/mpc4s-player-${version}.zip";
     sha256 = "0ssy5yzhnx5li4h8wgdbrv6jlgyx7qz4323a7qfhbnw1qvqnrapy";
   };

  buildInputs = [ jre8 ];

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp -R mpc4s-player*/* $out/program/
    cat > $out/bin/mpc4s <<-EOF
    #!${bash}/bin/bash
    $out/program/bin/mpc4s-player -java-home ${jre8} "\$@"
    EOF
    chmod 755 $out/bin/mpc4s
  '';

  meta = with lib; {
    description = ''
      Scala client library for MPD, HTTP interface to MPD via
      REST/Websockets, finally a Webclient for MPD.
    '';
    homepage = https://github.com/eikek/mpc4s;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
