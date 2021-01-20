let
  docspellsrc = builtins.fetchTarball {
    url = "https://github.com/eikek/docspell/archive/b57ceb67641617a0f3f7885c7f93ae0fa33d2e06.tar.gz";
    sha256 = "11xdk17vnyyh4jyd890w926albl5fmwbpkk5gbsnl9jnkc2wh2h8";
  };
  docspell = import "${docspellsrc}/nix/release.nix";

  sharrysrc = builtins.fetchTarball {
    url = "https://github.com/eikek/sharry/archive/b569d6926729e4486983780bf7ef4a7fc3be3cf2.tar.gz";
    sha256 = "0g10ik9hf1c44rlgn3lda0xhacmr45g538pj3zzbvdmph6f4hwi1";
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
