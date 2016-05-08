{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "1.0.0-M11-1";
  name = "coursier-${version}";

  src = fetchurl {
    url = "https://github.com/alexarchambault/coursier/raw/4b0589dc90d908715fa8a1a9e845469ccbc6a6b7/coursier";
    sha256 = "1zn9yj5vrzwxjd0f79lsbqlcbb49yrdnvw2zi8w2s996ga9ac5s2";
  };

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/coursier
    chmod 755 $out/bin/coursier
  '';

  meta = {
    homepage = https://github.com/alexarchambault/coursier;
    description = ''Pure Scala Artifact Fetching'';
    license = stdenv.lib.licenses.apl20;
  };
}
