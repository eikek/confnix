{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ ./hw-skyros.nix
      ../../common.nix

      ./settings.nix
      ./bind.nix
      ./nginx.nix
      ./email.nix
      ./gitblit.nix
      ./sitebag.nix
      ./myperception.nix
      ./fotojahn.nix
      ./shelter.nix
    ];

  boot.loader.grub.devices = [ "/dev/sda" ];

  networking = {
    hostName = "skyros";

    defaultMailServer = {
      domain = settings.primaryDomain;
      hostName = "localhost";
      root = "root@" + settings.primaryDomain;
    };

    useDHCP = true;
    firewall = {
      allowedTCPPorts = [ 22 25 587 143 80 443 29418 ];
    };
  };

  time.timeZone = "UTC";

  services.sitebag.enable = true;

  users.extraGroups = singleton {
    name = "publet";
    gid = config.ids.gids.publet;
  };
  users.extraUsers = singleton {
    name = "publet";
    uid = config.ids.uids.publet;
    extraGroups = ["publet"];
    description = "Publet daemon user.";
  };
  services.myperception = {
    enable = true;
    bindPort = 10100;
  };
  services.fotojahn = {
    enable = true;
    bindPort = 10200;
  };

  hardware = {
    cpu.intel.updateMicrocode = true;  #needs unfree
  };

  environment.systemPackages = with pkgs; [
    goaccess
  ];
}
