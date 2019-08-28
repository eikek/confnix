{ stdenv, fetchurl, unzip, jre8  }:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "0.3.0";
  name = "chee-${version}";

  src = fetchurl {
    url = "https://github.com/eikek/chee/releases/download/release%2F${version}/chee-${version}.zip";
    sha256 = "1g8dd0dlzdhhr4jiiz3vb62pikwl48rksppzg9z51d6qrc044vmi";
  };

  unpackPhase = ''
    ${unzip}/bin/unzip $src
  '';

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp -r chee-${version}/* $out/program
    sed -i 's,^java,${jre8}/bin/java,g' $out/program/chee
    ln -s $out/program/chee $out/bin/chee
    chmod 755 $out/program/chee
  '';

  meta = {
    description = "Chee is a command line tool for managing photos.";
    homepage = https://github.com/eikek/chee;
    license = licenses.gpl3;
  };
}
