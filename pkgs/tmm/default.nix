{stdenv, fetchurl, jre, libmediainfo, libzen, coreutils }:

stdenv.mkDerivation rec {
  version = "2.9.15_69b6104";
  name = "tinymediamanager-${version}";

  src = fetchurl {
    url = "http://release.tinymediamanager.org/v2/dist/tmm_${version}_linux.tar.gz";
    sha256 = "0cnf5imqp0047cgvikd5b50yk49lbq1kf84nmap9pw8mv2wp93zq";
  };

  buildInputs = [ ];

  unpackPhase = ''
    echo $src
    mkdir tmm-unpack
    tar -xzf $src -C tmm-unpack/
  '';

  installPhase = ''
    mkdir -p $out/{bin,program}
    cp -R tmm-unpack/* $out/program/
    cat > $out/bin/tinyMediaManager <<-EOF
    #!/usr/bin/env bash

    mkdir -p ~/.tmm
    for f in $out/program/*; do
      ln -nsf "\$f" "\$HOME/.tmm/\$(basename \$f)"
    done

    export PATH="${jre}/bin:${coreutils}/bin:\$PATH"
    export LD_LIBRARY_PATH="${libzen}/lib:${libmediainfo}/lib:\$LD_LIBRARY_PATH"
    cd \$HOME/.tmm
    ./tinyMediaManager.sh
    EOF
    chmod 755 $out/bin/tinyMediaManager
  '';

  meta = {
    description = ''
      tinyMediaManager is a full featured media manager to organize and clean up your media library.
    '';
    homepage = http://www.tinymediamanager.org;
    license = stdenv.lib.licenses.apl2;
  };
}
