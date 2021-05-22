let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/cb522ee6eb9a1db125767d4a91059b8feaa694f4.tar.gz";
    sha256 = "1dxl9fpmcbyhwn6dgwrfb93648139l4pn86sqm4h2y7vqgkv847a";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

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
  inherit docspell sharry webact;
}
