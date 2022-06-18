{ config, pkgs, ... }:

{ services.solr = {
    enable = true;

  };

  nixpkgs.config.permittedInsecurePackages = [
    "solr-8.6.3"
  ];
}
