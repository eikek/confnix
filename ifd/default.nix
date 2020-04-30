let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/9ec75cf85eb12e97f56ba4de500573def03ad625.tar.gz";
    sha256 = "0l0w70zmin6ccs0ah7xgvqb99d9bdprqdw4iw0dd4z8519jfb66j";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

  sharrysrc = builtins.fetchTarball {
    url = "https://github.com/eikek/sharry/archive/01fce706c68f5b0af26c1ebff5fcd698b7f21eed.tar.gz";
    sha256 = "0cssc3ryfsa788plvfmmvxfd121ppnp9q0lbf7qw8qwhi881kpgw";
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
