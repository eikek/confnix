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
#        ${pkgs.xlibs.xrandr}/bin/xrandr --output VGA-1 --mode 1440x900 --pos 0x0 --output VGA-0 --mode 1920x1200 --pos 1440x0
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
    extraHosts = ''
      127.0.0.1 macnix bluecare-n46_1

      # https://intranet/x/HIGkAQ
      192.168.13.27 larnags.int
      192.168.13.28 larnags.int.backend
      192.168.13.73 larnags.hii
      192.168.13.75 larnags.sta larnags.sta1
      192.168.13.76 larnags.sta2
      192.168.13.77 larnags.sta.backend larnags.sta.backend1
      192.168.13.78 larnags.sta.backend2
      192.168.13.79 larnags.sta.dbmaster
      192.168.13.80 larnags.sta.dbslave1
      192.168.13.81 larnags.sta.dbslave2
    '';
    hostName = "bluecare-n46_1";
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
