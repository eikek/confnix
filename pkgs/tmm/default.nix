{stdenv, lib, fetchurl, openjdk11, libmediainfo, libzen, coreutils-full }:
let
  wrapper = script: ''
    #!/usr/bin/env bash

    mkdir -p ~/.tmm
    for f in $out/program/*; do
      ln -nsf "\$f" "\$HOME/.tmm/\$(basename \$f)"
    done

    export PATH="${openjdk11}/bin:${coreutils-full}/bin:\$PATH"
    export LD_LIBRARY_PATH="${libzen}/lib:${libmediainfo}/lib:\$LD_LIBRARY_PATH"
    cd \$HOME/.tmm
    ${script}
  '';
in
stdenv.mkDerivation rec {
  version = "2.9.17_a55d726";
  name = "tinymediamanager-${version}";

  src = fetchurl {
    url = "https://eknet.org/pkgs/tmm_${version}_linux.tar.gz";
    sha256 = "0l0rilpqp3gy4a6jnbdmj0cs8ri66q7sp528fpy5isxjfqvcrxrs";
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
    ${wrapper "./tinyMediaManager.sh"}
    EOF
    cat > $out/bin/tinyMediaManagerCMD <<-EOF
    ${wrapper "./tinyMediaManagerCMD.sh \\$@"}
    EOF
    chmod 755 $out/bin/tinyMediaManager*
    ln -s tinyMediaManagerCMD $out/bin/tmm
  '';

  meta = {
    description = ''
      tinyMediaManager is a full featured media manager to organize and clean up your media library.
    '';
    homepage = http://www.tinymediamanager.org;
    license = lib.licenses.asl20;
  };
}
