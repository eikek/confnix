{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      ../common.nix
    ]

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

  services.ntp.enable = true;

  programs = {
    ssh.startAgent = false;
    bash.enableCompletion = true;
    zsh.enable = true;
  };


  users.extraUsers.eike = {
    isNormalUser = true;  # unstable
    name = "eike";
    group = "users";
    uid = 1000;
    createHome = true;
    home = "/home/eike";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "audio" "messagebus" "systemd-journal" ];
  };

  hardware = {
    #cpu.intel.updateMicrocode = true;  #needs unfree
  };

}
