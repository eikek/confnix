{stdenv, lib, fetchurl, jre8_headless, unzip, bash}:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "pickup-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/pickup/releases/download/v${version}/pickup-admin-${version}.zip";
     sha256 = "08b81n52ljgrk3j03schixi83x8phqm80h4x7xjbbmxx94zvg10b";
   };

  buildInputs = [ jre8_headless ];

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp -R pickup-*/* $out/program/
    cat > $out/bin/pickup-admin <<-EOF
    #!${bash}/bin/bash
    $out/program/bin/pickup-admin -java-home ${jre8_headless} "\$@"
    EOF
    chmod 755 $out/bin/pickup-admin
  '';

  meta = with lib; {
    description = "Pickup is a simple personal backup solution utilising duplicity.";
    homepage = https://github.com/eikek/pickup;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
