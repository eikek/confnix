{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "1.7";
  name = "clojure-docs-${version}";

  src = fetchgit {
    url = "https://github.com/clojure/clojure.git";
    rev = "11891e95edc8323b0739f7ab56cda10bdf56c996"; #refs/heads/gh-pages
    sha256 = "181dw68g9v6qnfl9r65yl7qm79a12zwi89nmyf6c6kkq7ihv75l3";
    name = "clojure-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
