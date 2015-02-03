{stdenv, fetchurl}:

let
  mkJavaDoc = major: version: sha: stdenv.mkDerivation rec {
    inherit version;
    name = "openjdk-${major}-doc";
    src = fetchurl {
      url = "mirror://debian/pool/main/o/openjdk-${major}/openjdk-${major}-doc_${version}_all.deb";
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

 jdk7 = mkJavaDoc "7" "7u75-2.5.4-1" "0d85z6dvwlsaqw5caqm0vyw1wn60x1d2lwhcxhwwyd0h69887rim";
 jdk8 = mkJavaDoc "8" "8u40~b22-2" "15s1za6yjdz06ysswnqpfjwi1dg3z9n6k73d5l83kqndsrh1vlas";

}
