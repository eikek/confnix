{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "3.3.2";
  name = "twitter-bootstrap-${version}";

  src = fetchgit {
    url = https://github.com/twbs/bootstrap;
    rev = "refs/tags/v${version}";
    name = "twitter-bootstrap-${version}-git";
    sha256 = "0gs1vsr5rlwdkwh32q9d3l27k0p0v4bmpbks1j8yc6q5qgjyrvwv";
  };

  installPhase = ''
    mkdir $out
    mv * $out
  '';
}
