let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/7301da901c2b7c28ab87c75c0002b2181892b225.tar.gz";
    sha256 = "1y9d1y64060rkim598rn7i8r62gjcn40y216s7xrgp25xpbggzl5";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

  dsc = builtins.fetchGit {
    url = "https://github.com/docspell/dsc";
    #rev = "acee43852629516df6847368b9b115f854405a8f";
    ref = "refs/tags/v0.5.0";
  };

  sharrysrc = builtins.fetchTarball {
    url = "https://github.com/eikek/sharry/archive/f984c34bd03ac844b9792b0338747ee632c93512.tar.gz";
    sha256 = "0062hzg27mzdbd69nxwjvrpaa6286gv39gh2mnpazak73bllgc6m";
  };
  sharry = import "${sharrysrc}/nix/release.nix";

  webactsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/webact/archive/bf68e8d1ffa6a70d1ae8179b2cbc826cbe452a42.tar.gz";
    sha256 = "197plafinzp4l7id16gl8471ra4j99bjw7dds3a71m69jp08iif5";
  };
  webact = import "${webactsrc}/nix/release.nix";
in {
  inherit docspell sharry webact dsc;
}
