# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-ithaka.nix
      ../common-desktop.nix
    ];

  boot.loader.grub.devices = [ "/dev/sda" ];

  # this should not be necessary, but my system did not start x otherwise
  boot.initrd.kernelModules = [ "nouveau" ];

  networking = {
    hostName = "ithaka";
    wireless = {
      enable = false;
    };

    useDHCP = true;
    wicd.enable = false;
    firewall.allowedTCPPorts = [ 22 80 443 ];
  };

  services.mongodb = {
    enable = true;
    extraConfig = ''
      nojournal = true
      '';
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.splix pkgs.foomatic_filters ];

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "nouveau" ];
# doesn't work with nouveau, but with nvidia…
#    xrandrHeads = [ "DVI-I-1" "DVI-D-0" ];

    # for some unknown reason, another dm won't let me login, only root
    # kdm allows me to login, but not root...
    displayManager.kdm.enable = false;
    displayManager.lightdm.enable = true;
    # my weird monitor setup :) this is needed when using nouveau
    displayManager.sessionCommands = ''
      xrandr --output DVI-I-1 --left-of DVI-D-1
    '';

    displayManager.session = [{
      manage = "window";
      name = "cstumpwm";
      start = ''exec /home/eike/bin/stumpwm'';
    }];
  };

  nixpkgs = {
    config = {
      firefox = {
        enableAdobeFlash = true;
      };
    };
  };

  environment.pathsToLink = [ "/" ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
