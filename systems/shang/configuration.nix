{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-shang.nix
      ../../common-desktop.nix
    ];

#  boot.kernelPackages = pkgs.linuxPackages_4_0;
  networking = {
    firewall = {
      allowedTCPPorts = [ 8080 ];
    };
  };

  boot.loader = {
    gummiboot.enable = true;
    gummiboot.timeout = 5;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd.kernelModules = [ "nouveau" "fbcon" ];

  networking = {
    hostName = "shang";
    hostId = "b43f128a";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;

#    nat = {
#      enable = true;
#      externalInterface = "enp3s0";
#      internalInterfaces = [ "ve-+" ];
#    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "nouveau" ];
  };

  environment.pathsToLink = [ "/" ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
