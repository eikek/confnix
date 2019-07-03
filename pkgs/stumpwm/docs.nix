{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "1.0.0";
  name = "stumpwm-docs-${version}";

  src = fetchgit {
    url = https://github.com/stumpwm/stumpwm.github.io.git;
    rev = "refs/heads/master";
    sha256 = "1qwffn8v7s25dr4rp0mp54f7hcf090y0crsf07q0x6jxm610rcaw";
    name = "stumpwm-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
