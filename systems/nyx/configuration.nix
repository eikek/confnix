{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-nyx.nix
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
    initrd.luks.devices = [
      {device = "/dev/sda5"; name = "rootfs"; }
    ];
    kernelPackages = pkgs.linuxPackages_4_0;
  };

  i18n = {
    consoleKeyMap = pkgs.lib.mkOverride 10 "de";
  };

  networking = {
    hostName = "nyx";
    wireless = {
      enable = false;  # would enable wpa_supplicant. not needed with wicd
      userControlled.enable = true;
      interfaces = [ "wlp2s0" ];
    };

    useDHCP = true;
    wicd.enable = true;

    nat = {
      enable = true;
      externalInterface = "wlp2s0";
      internalInterfaces = [ "ve-+" ];
    };
  };

  services.acpid.enable = true;
  services.sitebag.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "intel" ];
  };

  environment.pathsToLink = [ "/" ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
