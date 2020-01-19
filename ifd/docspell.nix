let
  version = "0.2.0";
  src = builtins.fetchTarball "https://github.com/eikek/docspell/archive/master.tar.gz";
  docspell = import "${src}/nix/release.nix";
in {
  currentPkg = docspell.pkg version;
  modules = docspell.modules;
}
