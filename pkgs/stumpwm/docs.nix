{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "1.0.0";
  name = "stumpwm-docs-${version}";

  src = fetchgit {
    url = https://github.com/stumpwm/stumpwm.github.io.git;
    rev = "refs/heads/master";
    sha256 = "0hz389k0v0jm9ncjqfh3jfpli1l7hhvljx04ihxmb08nc8ymrad8";
    name = "stumpwm-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
