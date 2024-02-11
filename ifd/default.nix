let
  webactsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/webact/archive/05bccd47e8b31bbc3ce2fcaa0f97481a1508a7a8.tar.gz";
    sha256 = "0lb920b0bdbg5r4489cc1y9lf88g05zbb8imcswsiml8ih6h38iw";
  };
  webact = import "${webactsrc}/nix/release.nix";
in {
  inherit webact;
}
