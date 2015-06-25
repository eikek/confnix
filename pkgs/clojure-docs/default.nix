{stdenv, fetchgit}:

stdenv.mkDerivation rec {
  version = "1.6";
  name = "clojure-docs-${version}";

  src = fetchgit {
    url = "https://github.com/clojure/clojure.git";
    rev = "757a1d952821914e20f7d64910acfb7f48adf23d"; #refs/heads/gh-pages
    sha256 = "0b1nxywk67qnmspr5myyml9zi2dhhjvgy41yigxlnm0hlb6yjinv";
    name = "clojure-docs-${version}-git";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
