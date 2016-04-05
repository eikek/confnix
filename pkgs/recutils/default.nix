{ fetchurl, stdenv, emacs, curl, check, bc, libgcrypt, libgpgerror, libuuid, readline }:

stdenv.mkDerivation rec {
  name = "recutils-1.7";

  src = fetchurl {
    url = "mirror://gnu/recutils/${name}.tar.gz";
    sha256 = "0cdwa4094x3yx7vn98xykvnlp9rngvd58d19vs3vh5hrvggccg93";
  };

  doCheck = true;

  buildInputs = [ curl emacs libgcrypt libgpgerror libuuid readline ] ++ (stdenv.lib.optionals doCheck [ check bc ]);

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/
    cp etc/{*.el,*.elc} $out/share/emacs/site-lisp/
  '';

  meta = {
    description = "Tools and libraries to access human-editable, text-based databases";

    longDescription =
      '' GNU Recutils is a set of tools and libraries to access
         human-editable, text-based databases called recfiles.  The data is
         stored as a sequence of records, each record containing an arbitrary
         number of named fields.
      '';

    homepage = http://www.gnu.org/software/recutils/;

    license = stdenv.lib.licenses.gpl3Plus;

    platforms = stdenv.lib.platforms.all;
    maintainers = [ ];
  };
}
