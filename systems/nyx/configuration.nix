{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-nyx.nix
      ../../common-desktop.nix
    ];

  boot.loader.grub.devices = [ "/dev/sda" ];
  boot.initrd.luks.devices = [ { device = "/dev/sda5"; name = "rootfs"; }];

  networking = {
    hostName = "nyx"; # Define your hostname.
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
