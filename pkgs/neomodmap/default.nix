{ stdenv, fetchurl, xlibs, kbd }:

let
  neoMap = fetchurl {
    url = http://neo-layout.org/neo_de.xmodmap;
    sha256 = "0xv753a6gwjz2crr87dmhbhq5hmjq391r3l029cv0ffw0rb6ppwc";
  };

in
stdenv.mkDerivation rec {
  version = "2472";

  name = "neo_de-${version}-keymap";

  src = ./.;

  patchPhase = ''
    substituteInPlace neomodmap.sh --replace "xmodmap" "${xlibs.xmodmap}/bin/xmodmap"
    substituteInPlace neomodmap.sh --replace "setxkbmap" "${xlibs.setxkbmap}/bin/setxkbmap"
    substituteInPlace neomodmap.sh --replace "xset" "${xlibs.xset}/bin/xset"
    substituteInPlace neomodmap.sh --replace "neo_de.modmap" "${neoMap}"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp neomodmap.sh $out/bin

    mkdir -p $out/share/keymaps/i386/neo
    cp neo.map $out/share/keymaps/i386/neo
  '';
}
