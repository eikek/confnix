let
  username = "linda";
  usermod = (import ../../modules/user.nix username);
  printer = import ../../modules/printer.nix;
in
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-limnos.nix
      ../../modules/accounts.nix
      ../../modules/bluetooth.nix
      ../../modules/fonts.nix
      ../../modules/ids.nix
      ../../modules/java.nix
      ../../modules/latex.nix
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/software.nix
      ../../modules/vbox-host.nix
      usermod
      printer.home
    ] ++
    (import ../../pkgs/modules.nix);

  boot = {
    initrd.luks.devices = {
      crootfs = { device = "/dev/nvme0n1p3"; preLVM = true; };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems =
  let
    mounts = {
      "/mnt/data" = {
        device = "/dev/disk/by-label/data";
        fsType = "xfs";
        options = ["auto" "user" "rw" "exec" "suid" "async"];
        noCheck = true;
      };
    };
  in mounts // (builtins.listToAttrs (map (mp:
    { name = "/mnt/nas/" + mp;
      value = {
        device = "//files.home/" + mp;
        fsType = "cifs";
        options = ["noauto" "user" "username=linda" "password=linda" "uid=1000" "gid=100" "vers=2.0" ];
        noCheck = true;
      };
    }) ["data" "linda"]));

  security = {
    pam.enableSSHAgentAuth = true;
    wrappers."mount.cifs".source = "${pkgs.cifs-utils}/bin/mount.cifs";
  };

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  users.extraGroups.vboxusers.members = [ "linda" ];

  users.groups.kvm = {
    members = [ "linda" ];
  };

  virtualisation.virtualbox.host.enable = true;
  ## Requires to recompile virtualbox
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  services.webact = {
    enable = true;
    app-name = "Webact Limnos";
    userService = true;
    script-dir = "/home/linda/.webact/scripts";
    tmp-dir = "/home/linda/.webact/temp";
    extra-packages = [ pkgs.ammonite pkgs.coreutils ];
    extra-path =
      [ "/run/current-system/sw/bin"
      ];
    env = {
      "DISPLAY" = ":0";
    };
    bind.address = "localhost";
  };

  networking = {
    hostName = "limnos";
    networkmanager = {
      enable = true;
    };
    wireless = {
      enable = false; #networkmanager is true
      interfaces = [ "wlp2s0" ];
    };
    useDHCP = false; # networkmanager is true
  };

  environment.pathsToLink = [ "/" ];
  time.timeZone = "Europe/Berlin";

  nixpkgs.config = {
    allowUnfree = true;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "ondemand";
  };

  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = false;
    openFirewall = true;
  };

  services.acpid.enable = true;

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;

    xkbVariant = pkgs.lib.mkForce "";

    libinput = {
      enable = true;
    };
    
    desktopManager = {
      gnome.enable = true;
    };

    displayManager = {
      gdm.enable = true;
    };
  };
  programs = {
    gnome-disks.enable = true;
    gphoto2.enable = true;
  };

  software.tools = [];
  software.devel = [];
  software.extra =
    let
      myR = pkgs.rWrapper.override {
        packages = with pkgs.rPackages;
          [ ggplot2
          ];
      };
    in
    with pkgs;
  [
    arc-theme
    calibre
    digikam
    emacs
    ghostscript
    gnome-icon-theme
    gnome-themes-standard
    gnome.evince
    gnome.gnome-calendar
    gnome.gnome-clocks
    gnome.gnome-disk-utility
    gnome.gnome-maps
    gnome.gnome-notes
    gnome.gnome-power-manager
    gnome.gnome-shell-extensions
    gnome.gnome-themes-extra
    gnome.gnome-themes-standard
    gnome.gnome-themes-standard
    gnome.gnome-tweak-tool
    gnome.gnome-tweaks
    gnome.gnome-usage
    gnome.gnome-weather
    gnome.nautilus
    gnome.shotwell
    gnome.sushi
    gnomeExtensions.appindicator
    gnomeExtensions.cpufreq
    gnomeExtensions.gtile
    gnomeExtensions.mounter
    gnomeExtensions.tweaks-in-system-menu
    gphoto2
    keepassx2
    libreoffice
    mediathekview
    myR
    networkmanager-openvpn
    ocrmypdf
    okular
    pandoc
    rstudio
    sambaFull
    signal-desktop
    smbclient
    smbnetfs
    thunderbird
    virtualbox
    vlc
    wpsoffice
    youtube-dl
    zathura
    zoom-us
  ];

  services.gvfs.enable = true;

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

  system.stateVersion = "21.05";
}
