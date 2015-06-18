{ stdenv, fetchsvn, python27, pygtk, bash, writeScript }:

stdenv.mkDerivation rec {
  version = "2471";

  name = "neo2-osd-${version}";

  src = fetchsvn {
    url = "https://svn.neo-layout.org/linux/osd";
    sha256 = "";
  };

  patchPhase = ''
    substituteInPlace *.py --replace "python" "${python27}/bin/python"
  '';

  installPhase = ''
     mkdir -p $out/{bin,program}
     mv * $out/program
     cat > $out/bin/neo2osd << EOF
     #!${bash}/bin/bash -e
     export PYTHONPATH=$PYTHONPATH
     export NIX_LDFLAGS="$NIX_LDFLAGS"
     $out/program/OSDneo2.py
     EOF
     chmod a+x $out/bin/neo2osd
  '';

  buildInputs = [ pygtk ];

}
