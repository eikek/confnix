{ pkgs ? import <nixpkgs> {} }:
let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom);

  custom = {
    sitebag = callPackage ./sitebag {};
    gitblit = callPackage ./gitblit {};
    exim = callPackage ./exim {};
  };

in { custom = custom; }
