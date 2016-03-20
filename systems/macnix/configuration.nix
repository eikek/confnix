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

  fonts.fontconfig = {
#    dpi = 120;
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
  ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };
}
