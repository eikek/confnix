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
    url = "https://github.com/eikek/webact/archive/fa527408ed27f03fdfdda447eed66a3d04e99f5c.tar.gz";
    sha256 = "1zknhbj6rk01phsds8hy9yw70dyx4wm9f93dfc7wqdsv6bk2b0zy";
  };
  webact = import "${webactsrc}/nix/release.nix";
in {
  inherit docspell sharry webact;
}
