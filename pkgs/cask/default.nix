{ stdenv, fetchurl, bash, emacs, python27Packages, which } :

stdenv.mkDerivation rec {

  version = "0.7.4";

  name = "cask-${version}";

  src = fetchurl {
    url = "https://github.com/cask/cask/archive/v${version}.tar.gz";
    name = "cask-src-git-${version}.tar.gz";
    sha256 = "0za3in46qf02fd5gsficphgr0df3xicbf0pl8285q8gwa0ffm0xi";
  };

  buildPhase = "true";

  patchPhase = ''
    sed -i 's,/usr/bin/env python,${python27Packages.python}/bin/python,g' bin/cask
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
    mv $out/bin/cask $out/bin/_cask
    cat > $out/bin/cask <<-"EOF"
    #!${bash}/bin/bash
    if ! ${which}/bin/which emacs > /dev/null 2>&1 && [ -z "$EMACS" ];
    then
        export EMACS=${emacs}/bin/emacs
    fi
    $(dirname $0)/_cask "$@"
    EOF
    chmod 755 $out/bin/cask
  '';

  meta = {
    description = "Project management tool for Emacs";
    license = stdenv.lib.licenses.gpl3;
    homepage = https://github.com/cask/cask/;
    maintainers = [ stdenv.lib.maintainers.eikek ];
  };
}
