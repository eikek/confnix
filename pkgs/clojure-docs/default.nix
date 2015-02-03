{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "1.6";
  name = "clojure-docs-${version}";

  src = fetchgit {
    url = "https://github.com/clojure/clojure.git";
    rev = "refs/heads/gh-pages";
    sha256 = "18spfi666dj6asncvibic8ljn0k0kljakykzaqr28jh2hjjd91a0";
    name = "clojure-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
