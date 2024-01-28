{ config, pkgs, ... }:
{
  imports = [
    ../pkgs/solr/module.nix
  ];

  nixpkgs = {
    config = {
      packageOverrides = import ../pkgs;
    };
  };

  services.solr = {
    enable = true;
  };
}
