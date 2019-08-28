{stdenv, fetchurl, jre8_headless, unzip, bash}:

stdenv.mkDerivation rec {
  version = "0.1.0";
  name = "attentive-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/attentive/releases/download/v${version}/attentive-${version}.zip";
     sha256 = "03jyxnrjzd95phyq40j3spwwn8s3xgf2ddlx6q2l4jb1srd2an29";
   };

  buildInputs = [ jre8_headless ];

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp -R attentive-*/* $out/program/
    cat > $out/bin/attentive <<-EOF
    #!${bash}/bin/bash
    $out/program/bin/attentive -java-home ${jre8_headless} "\$@"
    EOF
    chmod 755 $out/bin/attentive
  '';

  meta = with stdenv.lib; {
    description = "A personal audio scrobble daemon.";
    homepage = https://github.com/eikek/attentive;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
