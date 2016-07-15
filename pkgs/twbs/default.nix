{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "3.3.4";
  name = "twitter-bootstrap-${version}";

  src = fetchgit {
    url = https://github.com/twbs/bootstrap;
    rev = "refs/tags/v${version}";
    name = "twitter-bootstrap-${version}-git";
    sha256 = "0ai4jqvb8kkbc68pphpp61gxspr6904czxs444aysa3r7c2m7fqx";
  };

  installPhase = ''
    mkdir $out
    mv * $out
  '';
}
