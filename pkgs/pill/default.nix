{stdenv, fetchurl, jre}:

stdenv.mkDerivation rec {
  version = "0.0.1";
  name = "pill-${version}";

  src = fetchurl {
    url = "https://eknet.org/main/projects/pill/pill-${version}.tar.gz";
    sha256 = "1aag8dkwcwb72ayqpdk6msia5qlwiwzxf47zi717lcwrv7v40847";
  };

  installPhase = ''
    mkdir -p $out/{bin,program}
    chmod +x pill
    sed -i 's,^java,${jre}/bin/java,g' pill
    cp pill pill-server
    sed -i 's,pill.Main,pill.Server,g' pill-server
    cp -r * $out/program
    cd $out/bin
    ln -snf ../program/pill .
  '';
  /**/

  meta = with stdenv.lib; {
    description = "A basic job scheduler for your scripts.";
    homepage = https://github.com/eikek/pill;
    license = licenses.gpl3;
    maintainers = [ maintainers.eikek ];
  };
}
