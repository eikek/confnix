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

  boot.isContainer = true;
  networking.firewall.allowedTCPPorts = [ config.services.solr.port ];

  services.solr = {
    enable = true;
  };
}
