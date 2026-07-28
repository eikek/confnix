{ config, pkgs, nixpkgs-unstable, ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    database = {
      enable = true;
      name = "immich";
      user = "immich";
    };
  };

}
