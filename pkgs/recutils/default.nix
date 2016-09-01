{ fetchurl, lib, recutils }:

lib.overrideDerivation recutils (attrs: rec {
  name = "recutils-1.7";

  src = fetchurl {
    url = "mirror://gnu/recutils/${name}.tar.gz";
    sha256 = "0cdwa4094x3yx7vn98xykvnlp9rngvd58d19vs3vh5hrvggccg93";
  };

  hardeningDisable = [ "format" ];

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/
    cp etc/{*.el,*.elc} $out/share/emacs/site-lisp/
  '';

  patches =  [ ];
})
