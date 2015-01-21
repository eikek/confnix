#with import <nixpkgs> {};
{stdenv, fetchgit, automake, texinfo, guile, guile-xcb, pkgconfig}:

stdenv.mkDerivation rec {

  name = "guile-wm-1.0";

  src = fetchgit {
    url = https://github.com/mwitmer/guile-wm.git;
    rev = "refs/tags/1.0";
    name = "guile-wm-1.0-git";
    sha256 = "1h8bnm96anr7j88m72z3g4kizdbkz797j5wpx63zxzy0zmvdz3ya";
  };

  buildInputs = [ automake texinfo guile guile-xcb pkgconfig ];

  preConfigure = ''
    configureFlags="
      --with-guile-site-dir=$out/share/guile/site
      --with-guile-site-ccache-dir=$out/share/guile/site
    ";
  '';
}
