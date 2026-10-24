let
  username = "linda";
  usermod = import ../../modules/user.nix { inherit username; };
  printer = import ../../modules/printer.nix;
  chromiummod = import ../../modules/chromium-proxy.nix username;
in
{ config, pkgs, lib, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hw-limnos.nix
      ../../modules/bluetooth.nix
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
      ../../modules/containers.nix
      usermod
      (import ../../modules/user.nix { username = "eike"; uid = 1020; })
      printer.home
    ] ++
    (import ../../pkgs/modules.nix);

  boot = {
    tmp.cleanOnBoot = true;
    initrd.luks.devices = {
      crootfs = { device = "/dev/nvme0n1p2"; preLVM = true; };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  age.secrets.eike.file = ../../secrets/eike.age;
  users.users.eike.hashedPasswordFile = config.age.secrets.eike.path;

  fileSystems =
    let
      mounts = {};
    in
    mounts // (builtins.listToAttrs (map
      (mp:
        {
          name = "/mnt/nas/" + mp;
          value = {
            device = "//files.home/" + mp;
            fsType = "cifs";
            options = [ "noauto" "user" "username=linda" "password=linda" "uid=1000" "gid=100" "vers=2.0" ];
            noCheck = true;
          };
        }) [ "data" "linda" ]));

  security = {
    pam.sshAgentAuth.enable = true;
    wrappers = {
      "mount.cifs" = {
        source = "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
        owner = "root";
        group = "root";
      };
    };
  };

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  users.extraGroups.vboxusers.members = [ "linda" ];

  users.groups.kvm = {
    members = [ "linda" ];
  };

  ## Requires to recompile virtualbox
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  # services.webact = {
  #   enable = true;
  #   app-name = "Webact Limnos";
  #   userService = true;
  #   script-dir = "/home/linda/.webact/scripts";
  #   tmp-dir = "/home/linda/.webact/temp";
  #   extra-packages = [ pkgs.ammonite pkgs.coreutils ];
  #   extra-path =
  #     [
  #       "/run/current-system/sw/bin"
  #     ];
  #   env = {
  #     "DISPLAY" = ":0";
  #   };
  #   bind.address = "localhost";
  # };

  services.pipewire.enable = lib.mkForce false;
  console.keyMap = lib.mkForce "de";
  i18n.defaultLocale = lib.mkForce "de_DE.UTF-8";

  networking = {
    hostName = "limnos";
    networkmanager = {
      enable = true;
    };
    wireless = {
      interfaces = [ "wlp2s0" ];
    };
    useDHCP = false; # networkmanager is true
  };

  environment.pathsToLink = [ "/" ];
  time.timeZone = "Europe/Berlin";

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "ondemand";
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  services.acpid.enable = true;

  services.desktopManager = {
    gnome.enable = true;
  };

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;

    xkb = { variant = pkgs.lib.mkForce ""; };

    displayManager = {
      gdm.enable = true;
    };
  };

  services.libinput = {
    enable = true;
  };

  programs = {
    gnome-disks.enable = true;
    gphoto2.enable = true;
  };

  software.tools = [ ];
  software.devel = [ ];
  software.extra =
    let
      myR = pkgs.rWrapper.override {
        packages = with pkgs.rPackages;
          [
            ggplot2
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
      evince
      gnome-calendar
      gnome-clocks
      gnome-disk-utility
      gnome-maps
      gnome-notes
      gnome-power-manager
      gnome-shell-extensions
      gnome-themes-extra
      gnome-tweaks
      gnome-weather
      nautilus
      sushi
      gnomeExtensions.appindicator
      #gnomeExtensions.cpufreq
      gnomeExtensions.gtile
      gphoto2
      keepassxc
      libreoffice
      mediathekview
      myR
      networkmanager-openvpn
      ocrmypdf
      pandoc
      sambaFull
      signal-desktop
      shotwell
      samba
      smbnetfs
      thunderbird
      virtualbox
      vlc
      wpsoffice
      yt-dlp
      zathura
    ];

  services.gvfs.enable = true;

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true; #needs unfree
    opengl.driSupport32Bit = true;
  };

  system.stateVersion = "26.05";
}
