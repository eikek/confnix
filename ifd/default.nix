let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/efc73c1060c90fc337965efe3c7c1fd8d435e02e.tar.gz";
    sha256 = "1dkh8zbs4482iczvap2m90jh3z0gbhmq3qlj5a94hq3zapxfndhw";
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
