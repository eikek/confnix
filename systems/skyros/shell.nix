with import <nixpkgs> {};
let
  makevm = writeScript "makevm.sh" ''
  #!${bash}/bin/bash -e
  nix-build '<nixpkgs/nixos>' -A config.system.build.virtualBoxOVA
  '';
in
runCommand "zsh" {
  buildInputs = [ nix ];
  shellHook = ''
     alias makevm='${makevm}'
  '';
  NIX_PATH = "nixpkgs=https://github.com/nixos/nixpkgs/archive/release-14.12.tar.gz:nixos-config=/home/eike/workspace/projects/confnix-master/systems/skyros/testvm.nix";
  NIXOS_CONFIG = "/home/eike/workspace/projects/confnix-master/systems/skyros/testvm.nix";
} ""
