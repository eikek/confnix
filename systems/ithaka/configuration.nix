{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-ithaka.nix
      ../../common-desktop.nix
      ../../env-home.nix
      ../../env-vbox.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" ];
    };
    kernelPackages = pkgs.linuxPackages_4_0;
    # this should not be necessary, but my system did not start x otherwise
    initrd.kernelModules = [ "nouveau" ];
    blacklistedKernelModules = [ "snd-hda-intel" ];
  };

  networking = {
    hostName = "ithaka";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;

    nat = {
      enable = true;
      externalInterface = "enp5s0";
      internalInterfaces = [ "ve-+" ];
    };
  };

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
