{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-eknet.nix
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
    hostName = "eknet.org";
    nameservers =  settings.forwardNameServers;
    wireless = {
      enable = false;
    };

    useDHCP = true;
    wicd.enable = false;
    firewall = {
      allowedTCPPorts = [ 22 25 587 143 80 443 29418 ];
    };
  };

  time.timeZone = "UTC";

  services.sitebag.enable = true;

  hardware = {
    #cpu.intel.updateMicrocode = true;  #needs unfree
  };

}
