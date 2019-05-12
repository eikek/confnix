{stdenv, fetchurl, jre8_headless, unzip, bash}:

stdenv.mkDerivation rec {
  version = "0.2.0";
  name = "webact-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/webact/releases/download/v${version}/webact-${version}.zip";
     sha256 = "0gba4lzdh2r5rhn6q62iy8hp6w2zx9h8cd590s80w9mjxrnxcjx2";
   };

  buildInputs = [ jre8_headless ];

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp -R webact-*/* $out/program/
    cat > $out/bin/webact <<-EOF
    #!${bash}/bin/bash
    $out/program/bin/webact -java-home ${jre8_headless} "\$@"
    EOF
    chmod 755 $out/bin/webact
  '';

  meta = with stdenv.lib; {
    description = "Run actions from the web. Webact allows to manage scripts on the server and execute them.";
    homepage = https://github.com/eikek/webact;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
