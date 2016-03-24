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

  services.xserver = {
    displayManager = {
      sessionCommands = ''
        ${pkgs.xlibs.xrandr}/bin/xrandr --output VGA-0 --mode 2880x1800 --pos 0x00 --output VGA-1 --mode 1920x1200 --pos 2880x0
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
    extraHosts = "127.0.0.1 macnix";
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
