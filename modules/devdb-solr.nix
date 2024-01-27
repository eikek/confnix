{ config, pkgs, ... }:
# https://discourse.nixos.org/t/solr-has-been-removed-what-are-my-options/33504/3
{ services.solr = {
    enable = true;

  };

  nixpkgs.config.permittedInsecurePackages = [
    "solr-8.6.3"
  ];
}
