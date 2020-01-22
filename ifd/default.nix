let
  docspellsrc = builtins.fetchTarball "https://github.com/eikek/docspell/archive/master.tar.gz";
  docspell = import "${docspellsrc}/nix/release.nix";

  sharrysrc = builtins.fetchTarball "https://github.com/eikek/sharry/archive/master.tar.gz";
  sharry = import "${sharrysrc}/nix/release.nix";
in {
  inherit docspell sharry;
}
