{ config, pkgs, ... }:
let mykey = builtins.readFile /home/eike/.ssh/id_rsa.pub; in
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
    # this should not be necessary, but my system did not start x otherwise
    initrd.kernelModules = [ "nouveau" ];
    blacklistedKernelModules = [ "snd-hda-intel" ];
  };

  fonts.fontconfig = {
    dpi = 140;
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
    monitorSection = ''
      DisplaySize 698 393
    '';
    displayManager = {
      sessionCommands = ''
        xrandr --dpi 140
      '';
    };
  };

  environment.pathsToLink = [ "/" ];

  nix = {
    sshServe.enable = true;
    sshServe.keys = [ mykey ];
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
