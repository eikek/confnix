{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-macnix.nix
      ../../common-desktop.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" ];
    };
  };

  virtualisation.virtualbox.guest.enable = true;

  fonts.fontconfig = {
    dpi = 140;
  };

  services.xserver = {
    displayManager = {
      sessionCommands = ''
        xrandr --dpi 140
      '';
    };
  };

  fileSystems = {
    "/home/host" = {
      device = "home";
      fsType = "vboxsf";
      options = ["auto" "rw" "uid=1000" "gid=100" "exec"];
      noCheck = true;
      };
  };

  networking = {
    hostName = "macnix";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;
  };

  environment.pathsToLink = [ "/" ];

  environment.systemPackages = with pkgs; [
    tesseract
    mongodb
    mongodb-tools
    ansible2
  ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };
}
