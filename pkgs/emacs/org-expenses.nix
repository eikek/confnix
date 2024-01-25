{ pkgs, emacsPackages }:

pkgs.stdenv.mkDerivation rec {

  pname = "org-expenses";
  version = "0.0.1";
  name = "${pname}-${version}";

  src = pkgs.fetchFromGitHub {
    owner = "eikek";
    repo = "${pname}";
    rev = "47f972fd14516291ea33d0590f183583956b7888";
    sha256 = "14wy56lnfqnpp2l94n3yqdcarncs5nc23g0ak51ahi36aykl60gv";
  };

  buildInputs = [ pkgs.emacs ];
  propagatedUserEnvPkgs = with emacsPackages; [ dash s org ];

  unpackPhase = "true";

  # It used to work with `trivialBuild' and `packageRequires' list but
  # it doesn't do anymore. It seems as if the lisp files are stored
  # deep down below the `site-lisp' dir, but only the `site-lisp' dir
  # is in emacs load-path.
  buildPhase = ''
    cp -r $src/* .
    LDASH=$(find ${emacsPackages.dash}/share/emacs/site-lisp -type d | tail -n1)
    LES=$(find ${emacsPackages.s}/share/emacs/site-lisp -type d | tail -n1)
    emacs -L . -L $LDASH -L $LES --batch -f batch-byte-compile *.el
  '';

  installPhase = ''
    install -d $out/share/emacs/site-lisp
    install *.el *.elc $out/share/emacs/site-lisp
  '';
}
