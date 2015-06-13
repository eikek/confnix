{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "1.6";
  name = "clojure-docs-${version}";

  src = fetchgit {
    url = "https://github.com/clojure/clojure.git";
    rev = "refs/heads/gh-pages";
    sha256 = "00da6c3qrgw245vkn26a5hjhixx7dlm2pg5zbgnws7dyqh615dgv";
    name = "clojure-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
