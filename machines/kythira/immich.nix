{ config, pkgs, nixpkgs-unstable, ... }:
{
  services.immich = let
    unstable = nixpkgs-unstable.legacyPackages.${pkgs.stdenv.system};
  in {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    package = unstable.immich;
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

  environment.systemPackages = [ pkgs.immich-cli ];
}
