{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-eknet.nix
      ../common.nix
    ];

  boot.loader.grub.devices = [ "/dev/sda" ];

  networking = {
    hostName = "eknet.org";
    wireless = {
      enable = false;
    };

    useDHCP = true;
    wicd.enable = false;
    firewall = {
      allowedTCPPorts = [ 22 80 443 29418 ];
    };
  };

  time.timeZone = "UTC";

  services.mongodb = {
    enable = true;
  };

  services.sitebag.enable = true;
  services.gitblit.enable = true;
  services.exim.enable = true;
  services.exim.primaryHostname = config.networking.hostName;
  services.shelter.enable = true;

  hardware = {
    #cpu.intel.updateMicrocode = true;  #needs unfree
  };

}
