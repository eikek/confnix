{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "0.9.9";
  name = "stumpwm-docs-${version}";

  src = fetchgit {
    url = https://github.com/stumpwm/stumpwm.github.io.git;
    rev = "refs/heads/master";
    sha256 = "0bfh80v234nnaxih37xw4nklx8h3fq2p89kx231rp1bjhmjfq03h";
    name = "stumpwm-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
