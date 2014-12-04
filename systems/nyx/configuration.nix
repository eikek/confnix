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
    firewall = {
      allowedTCPPorts = [ 22 80 443 ];
    };
  };


  services.acpid.enable = true;
  services.mongodb.enable = true;
  services.sitebag.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "intel" ];

    # for some unknown reason, another dm won't let me login, only root
    # only kdm allows me to login, but not root...
    displayManager.kdm.enable = true;
    displayManager.lightdm.enable = false;
    displayManager.session = [{
      manage = "window";
      name = "cstumpwm";
      start = ''exec /home/eike/bin/stumpwm'';
    }];
  };

  environment.pathsToLink = [ "/" ];

  hardware = {
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
