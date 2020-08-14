let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/30d5abddd8d40cf8f4ee2fceecaa7eb4de0ed3ed.tar.gz";
    sha256 = "0wnfrcy48vh3h7g8fp7gif4nc34n5mnwnr7i6614mi0wxy03sbvh";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

  sharrysrc = builtins.fetchTarball {
    url = "https://github.com/eikek/sharry/archive/2da6b9ae78064d86c743fcbdb95daf08ccf675ef.tar.gz";
    sha256 = "081idn9m0xhx22ii1nwipybfsh28wgpnp2dknqqrmhjpw68mwc4y";
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
