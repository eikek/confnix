{ stdenv, fetchurl, autoconf, jdk, gcc }:

stdenv.mkDerivation rec {
  version = "0.2.4";
  name = "drip-${version}";

  src = fetchurl {
    url = "https://github.com/ninjudd/drip/archive/${version}.tar.gz";
    sha256 = "07amncslmfhai4sdj7sgnway1wni6dgphqdcvl17s1wsfllmxlly";
  };

  buildInputs = [ jdk ];

  patchPhase = ''
    sed -i "s|prefix=~/bin|prefix=$out|g" Makefile
    sed -i 's|ln -sf|cp |g' Makefile
  '';

  buildPhase = ''
    mkdir -p $out/bin
    make prefix=$out/bin install
    sed -i "s|gcc|${gcc}/bin/gcc|g" $out/bin/drip
  '';

  meta = {
    homepage = https://github.com/ninjudd/drip;
    description = ''Drip is a launcher for the Java Virtual Machine
    that provides much faster startup times than the java command. The
    drip script is intended to be a drop-in replacement for the java
    command, only faster.'';
    license = stdenv.lib.licenses.epl10;
  };
}
