with import <nixpkgs> {};
let
  nixos = "https://github.com/NixOS/nixpkgs-channels/archive/nixos-16.03.tar.gz";
in
stdenv.mkDerivation rec {
  name = "env";
  buildInputs = [ nix ];
  shellHook = ''
     SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

     export NIXOS_CONFIG="$(pwd)/testconf.nix";
     export NIX_PATH="nixpkgs=${nixos}:nixos-config=$(pwd)/testconf.nix:sshkey=$HOME/.ssh/id_rsa.pub";
  '';
}
