{stdenv, fetchurl, jre8_headless, unzip, bash}:

stdenv.mkDerivation rec {
  version = "0.3.1";
  name = "webact-${version}";

   src = fetchurl {
     url = "https://github.com/eikek/webact/releases/download/v${version}/webact-${version}.zip";
     sha256 = "0gs7i2id9z6g0k7jzz89im43nq255a9mzrkfh0l3wbvx86fp6mvb";
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
