{ stdenv, pkgs, fetchzip }:

let
  nodePackages = import <nixpkgs/pkgs/top-level/node-packages.nix> {
    inherit pkgs;
    inherit (pkgs) stdenv nodejs fetchurl fetchgit;
    neededNatives = [ pkgs.python ] ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.utillinux;
    self = nodePackages;
  };
in
nodePackages.buildNodePackage rec {
  version = "1.1.1";
  name = "elm-oracle-${version}";

  src = fetchzip {
    url = https://github.com/ElmCast/elm-oracle/archive/3fa02e417a93c3180df1fd588d22bdd82a58856a.zip;
    name = "elm-oracle-3fa02e41.zip";
    sha256 = "0xr7pv7pmxj0mpyp8d6b6id0fkjnfpp02pibmd041s5vb8mp8n83";
  };
}
