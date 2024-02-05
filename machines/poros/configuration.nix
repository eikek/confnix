{ config, nixos-hardware, agenix, lib, pkgs, ... }:
let
  mykey = builtins.readFile <sshpubkey>;
  printer = import ../../modules/printer.nix;
  usermod = import ../../modules/user.nix "eike";
  dockermod = import ../../modules/docker.nix [ "eike" ];
  macOsFirmware = import ./firmware.nix;
in
{
  imports =
    [ ./hw-config.nix
      nixos-hardware.nixosModules.apple-t2
      agenix.nixosModules.default
      ../../modules/accounts.nix
      ./bluetooth.nix
      ../../modules/dsc-watch.nix
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
      printer.home
      usermod
      dockermod
      macOsFirmware
    ];

  boot = {
    tmp.cleanOnBoot = true;
    initrd.luks.devices = {
      crootfs = {
        device = "/dev/nvme0n1p4"; preLVM = true;
      };
    };

    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    enableAllFirmware = false;
    apple-t2.enableAppleSetOsLoader = true;
  };

  networking = {
    hostName = "poros";
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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

  containers.dbpostgres =
    { config = import ../../modules/devdb-postgres.nix;
      autoStart = false;
    };
  containers.dbsolr =
    { config = import ../../modules/devdb-solr.nix;
      autoStart = false;
    };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    sshServe.enable = true;
    sshServe.keys = [ mykey ];
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
    agenix.packages.x86_64-linux.default
  ];

  system.stateVersion = "23.11";
}
