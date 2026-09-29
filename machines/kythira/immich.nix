{ config, pkgs, ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    package = pkgs.immich;
    mediaLocation = "/mnt/data1/immich";
    database = {
      enable = true;
      name = "immich";
      user = "immich";
    };
    environment = {
      "TZ" = "Europe/Paris";
    };
  };

  environment.systemPackages = [ pkgs.immich-go ];
}
