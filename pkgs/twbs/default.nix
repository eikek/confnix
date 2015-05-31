{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "3.3.4";
  name = "twitter-bootstrap-${version}";

  src = fetchgit {
    url = https://github.com/twbs/bootstrap;
    rev = "refs/tags/v${version}";
    name = "twitter-bootstrap-${version}-git";
    sha256 = "0wm0mq0p22zxycwf6dk4plbcflvc6z3iac0413qbbijxwqcq3k11";
  };

  installPhase = ''
    mkdir $out
    mv * $out
  '';
}
