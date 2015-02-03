{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "0.9.9";
  name = "stumpwm-docs-${version}";

  src = fetchgit {
    url = "https://github.com/stumpwm/stumpwm.github.io.git";
    rev = "refs/heads/master";
    sha256 = "0zsn7ldkbx75zzk919pjq4f5iwnsxq7cr1vb8kgs6az0rnc5ka67";
    name = "stumpwm-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
