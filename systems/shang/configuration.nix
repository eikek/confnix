{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-shang.nix
      ../../common-desktop.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_4_0;

  boot.loader.grub.devices = [ "/dev/sda" ];

  # this should not be necessary, but my system did not start x otherwise
  boot.initrd.kernelModules = [ "nouveau" ];

  networking = {
    hostName = "shang";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;

    nat = {
      enable = true;
      externalInterface = "enp3s0";
      internalInterfaces = [ "ve-+" ];
    };
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
