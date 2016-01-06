with import <nixpkgs> {};
let
  configfile = "virtualbox.nix";
  makevm = writeScript "makevm.sh" ''
  #!${bash}/bin/bash -e
  nix-build '<nixpkgs/nixos>' -A config.system.build.virtualBoxOVA
  '';
in
runCommand "zsh" {
  shellHook = ''
     alias makevm='${makevm}'
     export NIX_PATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=$PWD/${configfile}";
     export NIXOS_CONFIG="$PWD/${configfile}";
  '';
} ""
