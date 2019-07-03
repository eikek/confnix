{stdenv, fetchurl, unzip}:

let
  mkJavaDoc = major: version: sha: stdenv.mkDerivation rec {
    inherit version;
    name = "openjdk-${major}-doc";
    src = fetchurl {
      # the ftp mirrors are blocked by our fw…
      url = "http://ftp.de.debian.org/debian/pool/main/o/openjdk-${major}/openjdk-${major}-doc_${version}_all.deb";
      sha256 = "${sha}";
      name = "${name}-deb";
    };
    unpackPhase = ''
      ar vx $src
      tar -xf data.tar.xz
    '';
    installPhase = ''
      mkdir -p $out
      mv usr/share/doc/openjdk-${major}-jre-headless/* $out
    ''; #*/
  };
in {

 # http://ftp.de.debian.org/debian/pool/main/o/openjdk-11/
 jdk11 = mkJavaDoc "11" "11.0.4+10-1" "1q71s3wapqyn8iyxmrgqdjb8ranvrk7phh2bg8gkim6fmrxm72sj";
 jdk8 = mkJavaDoc "8" "8u212-b01-1~deb9u1" "14zi75dg4d6fypjbl4p46rir9jf8plmd57npsm90x1j846aj4f5y";
 jee7 = stdenv.mkDerivation rec {
   name = "javaee-7.0-doc";
   src = fetchurl {
     url = "http://dlc.sun.com.edgesuite.net/glassfish/4.0/release/javaee-api-7.0-javadoc.jar";
     sha256 = "1dmcchwh6h72767qvq2fg64mag4nbz5lxc6h097z6s86h9q83nbn";
   };
   buildInputs = [unzip];
   unpackPhase = "unzip $src";
   installPhase = "mkdir -p $out && mv * $out";
 };
}
