{ config, lib, pkgs, ... }:
let
  usermod = import ../../modules/user.nix { username = "eike"; };
  dockermod = import ../../modules/docker.nix [ "eike" ];
  dscwatchmod = import ../../modules/dsc-watch.nix "eike";
  chromiummod = import ../../modules/chromium-proxy.nix "eike";
in
{
  imports =
    [
      ./hw-x1gen13.nix
      ../../modules/androiddev.nix
      ../../modules/bluetooth.nix
      ../../modules/emacs.nix
      ../../modules/ergodox.nix
      ../../modules/flakes.nix
      ../../modules/fonts.nix
      ../../modules/ids.nix
      ../../modules/java.nix
      ../../modules/latex.nix
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/region-neo.nix
      ../../modules/software.nix
      ../../modules/vbox-host.nix
      ../../modules/xserver.nix
      ../../modules/zsa.nix
      usermod
      dockermod
      chromiummod
    ];

  boot = {
    tmp.cleanOnBoot = true;
    initrd.luks.devices = {
      crootfs = {
        device = "/dev/nvme0n1p1";
        preLVM = true;
      };
    };

    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth = {
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          ControllerMode = "bredr";
        };
      };
    };
  };


  networking = {
    hostName = "xps";
    wireless.enable = true; # Enables wireless support via wpa_supplicant.
    useDHCP = true;
  };

  services.udisks2 = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.X11Forwarding = true;
    #settings.PermitRootLogin = "yes";
  };

  environment.systemPackages = with pkgs; [
    libreoffice
    slack
    zoom-us
    kind
    kubectx
    kubectl
    kubernetes
    kubernetes-helm
    k9s
    kail
    jdk17
    sops
  ];

  system.stateVersion = "25.05";
}
