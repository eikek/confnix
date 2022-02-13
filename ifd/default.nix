let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/4aee69b6eef23bda20ecb5e79d6c7e671d274c42.tar.gz";
    sha256 = "1jlvsl207s7026k2l2x800a26j0hsrs2pbzz4wwr1604y7zabyw3";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

  dsc = builtins.fetchGit {
    url = "https://github.com/docspell/dsc";
    #rev = "acee43852629516df6847368b9b115f854405a8f";
    ref = "refs/tags/v0.6.2";
  };

  sharrysrc = builtins.fetchTarball {
    url = "https://github.com/eikek/sharry/archive/f984c34bd03ac844b9792b0338747ee632c93512.tar.gz";
    sha256 = "0062hzg27mzdbd69nxwjvrpaa6286gv39gh2mnpazak73bllgc6m";
  };
  sharry = import "${sharrysrc}/nix/release.nix";

  webactsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/webact/archive/05bccd47e8b31bbc3ce2fcaa0f97481a1508a7a8.tar.gz";
    sha256 = "0lb920b0bdbg5r4489cc1y9lf88g05zbb8imcswsiml8ih6h38iw";
  };
  webact = import "${webactsrc}/nix/release.nix";
in {
  inherit docspell sharry webact dsc;
}
