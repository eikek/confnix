{stdenv, fetchgit, buildGoPackage, perl, go}:

stdenv.mkDerivation rec {
  version = "0.0.8";
  name = "gossa-${version}";
  rev = "v0.0.8";

  buildInputs = [ perl go ];

  src = fetchgit {
    inherit rev;
    url = "https://github.com/pldubouilh/gossa";
    sha256 = "15xx8midi8rig1jiq5g2yawg7x24zx0krw28hxpb0qvnvp2lxlpk";
  };

  buildPhase = ''
    make build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp gossa $out/bin/
  '';
}
