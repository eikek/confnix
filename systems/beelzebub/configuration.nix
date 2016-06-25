{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-beelzebub.nix
      ../../common.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" ];
    };
    kernelPackages = pkgs.linuxPackages_4_4;
    # this should not be necessary, but my system did not start x otherwise
#    initrd.kernelModules = [ "nouveau" ];
  };

  i18n = {
    consoleKeyMap = pkgs.lib.mkOverride 20 "de";
  };

  users.extraGroups.vboxusers.members = [ "schwarzer" ];
  virtualisation.virtualbox.host.enable = true;

  users.groups.kvm = {
    members = [ "schwarzer" ];
  };

  networking = {
    hostName = "beelzebub";
    firewall = {
      allowedTCPPorts = [ 80 443 ];
    };
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;
  };

  environment.pathsToLink = [ "/" ];
  time.timeZone = "Europe/Berlin";

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  security.pam.enableSSHAgentAuth = true;

  services.printing = {
    enable = true;
  };

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;

    xkbVariant = pkgs.lib.mkForce "";

    desktopManager = {
      kde4.enable = true;
    };

    displayManager = {
      kdm.enable = true;
      sessionCommands = ''
        export JAVA_HOME=${pkgs.jdk}/lib/openjdk
        export JDK_HOME=${pkgs.jdk}/lib/openjdk

        gpg-connect-agent /bye
        export GPG_TTY=$(tty)
        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"

        ${pkgs.xflux}/bin/xflux -l 47.5 -g 8.75
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
    mpd
    mpc_cli
    mplayer
    vlc
    cdparanoia
    lxdvdrip
    sox
    flac
    vorbisTools
#    soundkonverter
    dvdauthor
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
    surfraw
    chromium
    thunderbird

  # devel
    subversion
    python
    scala
    sbt
    clojure
    leiningen
    jdk
    maven
    ant
    silver-searcher
    global
#    tex
    R
    cask

  # other tools
    zathura
    ghostscript
    libreoffice
    sqliteman
    pandoc
    youtube-dl
    mediathekview
    python27Packages.pygments
    drip
    recoll
    recordmydesktop
    aspell
    aspellDicts.en
    aspellDicts.de
  ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
