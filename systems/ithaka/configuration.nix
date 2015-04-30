{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-ithaka.nix
      ../../common-desktop.nix
    ];

  boot.loader.grub.devices = [ "/dev/sda" ];

  # this should not be necessary, but my system did not start x otherwise
  boot.initrd.kernelModules = [ "nouveau" ];
  boot.blacklistedKernelModules = [ "snd-hda-intel" ];


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

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "nouveau" ];
# doesn't work with nouveau, but with nvidia…
#    xrandrHeads = [ "DVI-I-1" "DVI-D-0" ];

    # my weird monitor setup :) this is needed when using nouveau
    displayManager.sessionCommands = ''
      xrandr --output DVI-I-1 --left-of DVI-D-1
    '';
  };

  environment.pathsToLink = [ "/" ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
