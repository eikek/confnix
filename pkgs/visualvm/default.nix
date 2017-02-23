{stdenv, fetchurl, unzip, jdk}:

let
  packed = v: stdenv.lib.replaceChars ["."] [""] v;
in
stdenv.mkDerivation rec {
  version = "1.3.9";
  name = "visualvm-${version}";

  src = let v = packed version; in fetchurl {
    url = "https://github.com/visualvm/visualvm.src/releases/download/${version}/visualvm_${v}-ml.zip";
#    url = "https://java.net/projects/visualvm/downloads/download/release${v}/visualvm_${v}.zip";
    sha256 = "1zp4am06p7vbngs28pj9hx2mc4cnmlpy166h96agy6g1gwy7yxas";
  };

  buildInputs = [ unzip ];

  unpackPhase = let v = packed version; in ''
    unzip $src
    cd visualvm_${v}
  '';

  installPhase = ''
    mkdir -p $out/{bin,program}
    mv * $out/program
    cat >> $out/bin/visualvm <<-EOF
    #! /bin/env bash
    $out/program/bin/visualvm --jdkhome ${jdk}/lib/openjdk "\$@"
    EOF
    chmod 755 $out/bin/visualvm
  '';

  meta = with stdenv.lib; {
    description = "VisualVm";
    homepage = https://java.net/projects/visualvm;
    license = licenses.gpl2;
    maintainers = [ maintainers.eikek ];
  };
}
