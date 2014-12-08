{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ ./hw-eknet.nix
      ../../common.nix

      ./settings.nix
      ./bind.nix
      ./nginx.nix
      ./gitblit.nix
      ./email.nix
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

  hardware = {
    cpu.intel.updateMicrocode = true;  #needs unfree
  };

  environment.systemPackages = with pkgs; [
    goaccess
  ];
}
