{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-nyx.nix
      ../../common.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" ];
    };
    initrd.luks.devices = [
      {device = "/dev/sda5"; name = "rootfs"; }
    ];

    kernelPackages = pkgs.linuxPackages_4_8;
  };

  i18n = {
    consoleKeyMap = pkgs.lib.mkOverride 20 "de";
  };

  users.extraGroups.vboxusers.members = [ "schwarzer" ];

  users.groups.kvm = {
    members = [ "schwarzer" ];
  };

  networking = {
    hostName = "nyx";
    wireless = {
      enable = false;
      userControlled.enable = true;
    };
    useDHCP = true;
    wicd.enable = true;
  };

  environment.pathsToLink = [ "/" ];
  time.timeZone = "Europe/Berlin";

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  services.acpid.enable = true;
  security.pam.enableSSHAgentAuth = true;

  services.printing = {
    enable = true;
  };

  services.redshift = {
    enable = true;
    brightness.night = "0.8";
    temperature.night = 3500;
    latitude = "50.57";
    longitude = "10.42";
  };

  services.xserver = {
    videoDrivers = [ "intel" ];
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;

    xkbVariant = pkgs.lib.mkForce "";

    synaptics = {
      enable = true;
      twoFingerScroll = true;
      accelFactor = "0.001";
      buttonsMap = [ 1 3 2 ];
    };
    
    desktopManager = {
      kde4.enable = true;
    };

    displayManager = {
      kdm.enable = true;
      sessionCommands = ''
        export JAVA_HOME=${pkgs.jdk}/lib/openjdk
        export JDK_HOME=${pkgs.jdk}/lib/openjdk

        gpg-connect-agent /bye
        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gnupg/S.gpg-agent.ssh"
      '';
    };
  };

  nixpkgs = {
    config = {
      firefox = {
        enableAdobeFlash = true;
        icedtea = true;
      };
      chromium = {
        icedtea = true;
      };
    };
  };

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    fonts = with pkgs; [
      inconsolata
      source-code-pro  # unstable
      dejavu_fonts
      ttf_bitstream_vera
      terminus_font
    ];
  };

  users.extraUsers.schwarzer = {
    isNormalUser = true;
    name = "schwarzer";
    group = "users";
    uid = 1001;
    createHome = true;
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "audio" "messagebus" "systemd-journal" ];
  };

  environment.systemPackages =
  with pkgs;
  let
    # see https://nixos.org/wiki/TexLive_HOWTO
    tex = texlive.combine {
      inherit (texlive) scheme-medium collection-latexextra beamer moderncv moderntimeline cm-super inconsolata libertine;
    };
  in [
  # base
    nix-repl
    pinentry
    dhcp
    nmap
    iptables
    tcpdump
    cifs_utils
    aumix
    wicd
    ntfs3g
    emacs
    zile
    
  # images
    feh
    viewnior
    imagemagick
    jhead
    libjpeg
    gimp
    graphviz
    gnuplot
    plantuml

  # multimedia
    mplayer
    vlc
    cdparanoia
    lxdvdrip
    sox
    flac
    vorbisTools
#    soundkonverter
    lsdvd
    exiv2
    easytag
    ffmpeg
    calibre

  # x-window
    xlibs.xrandr
    xlibs.xmodmap
    xlibs.twm
    xlibs.xwd
    xlibs.xdpyinfo
    xsel
    xorg.xwininfo
    xfce.terminal
    compton
    xclip
    autorandr
    i3lock

  # web/email
    firefoxWrapper
    chromium
    thunderbird

  # devel
    subversion
    python
    scala
    sbt
    jdk
    silver-searcher
    global
    tex
    R
    cask

  # other tools
    lyx
    kde4.kopete
    kde4.l10n.de
    kde4.amarok
    torbrowser
    dropbox
    zathura
    ghostscript
    libreoffice
    wpsoffice
    sqliteman
    pandoc
    youtube-dl
    mediathekview
    python27Packages.pygments
    drip
    recordmydesktop
  ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
