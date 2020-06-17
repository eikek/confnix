let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/492f4d304f8dac3a336dadab88c4c3bc14b28c75.tar.gz";
    sha256 = "1mhib6sn72nymkljipkgj93jxjykg7mldn844vgwi10yp2nn7iqq";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

  sharrysrc = builtins.fetchTarball {
    url = "https://github.com/eikek/sharry/archive/d9cbb2bb5c818d807d9f5259021a774a499c6cb9.tar.gz";
    sha256 = "111hvx0y093rqibja3d65vim9pq9ck1mhjs17cg7jhsb4z8fijwh";
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
