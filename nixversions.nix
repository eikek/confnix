config:
let
  nixpkgs1909 = builtins.fetchTarball {
    url = "channels/nixos-19.09";
    sha256 = "157c64220lf825ll4c0cxsdwg7cxqdx4z559fdp7kpz0g6p8fhhr";
  };
  pkgs1909 = import nixpkgs1909 { config = config; system = "x86_64-linux"; };

  nixpkgsUnstable = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "sha256:03cxv9h218dj7kc5hb0yrclshgbq20plyrvnfdaw5payyy9gbsfr";
  };
  pkgsUnstable = import nixpkgsUnstable { config = config; system = "x86_64-linux"; };
in
{
  inherit pkgs1909 pkgsUnstable;

}
