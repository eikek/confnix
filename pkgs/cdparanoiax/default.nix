# a patched/devel version of cdparanoia that is compatible with newer
# (> 4.3) versions of gcc. for example, soundkonverter only compiles
# with the patched version of cdparanoia
# see this mail: http://www.mythtv.org/pipermail/mythtv-users/2012-January/326912.html

{ stdenv, fetchsvn, autoconf }:

stdenv.mkDerivation rec {
  name = "cdparanoia-III-10.3pre";

  src = fetchsvn {
    name ="cdparanoia-III-10.3pre-src";
    url = "http://svn.xiph.org/trunk/cdparanoia";
    sha256 = "14p5r35vw5zmp05a8wydjs07wrg28jl1brpkbm3cim2pjnh5bcw5";
  };

  buildInputs = [ autoconf ];

  preConfigure = " autoconf ";

  meta = {
    homepage = http://xiph.org/paranoia;
    description = "A tool and library for reading digital audio from CDs";
  };
}
