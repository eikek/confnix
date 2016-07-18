{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-lenni.nix
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
      { device = "/dev/sda2"; name = "rootfs"; preLVM = true; }
    ];
  };

  networking = {
    hostName = "lenni";
    wireless = {
      enable = false;  # would enable wpa_supplicant. not needed with wicd
    };
    useDHCP = true;
    wicd.enable = true;
  };

  services.acpid.enable = true;

  nixpkgs = {
    config = {
      allowUnfree = pkgs.lib.mkForce false;
    };
  };

  environment.pathsToLink = [ "/" ];
}
