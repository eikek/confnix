{ config, pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  time.timeZone = "Europe/Berlin";

  boot = {
    kernelPackages = pkgs.linuxPackages_4_6;
    cleanTmpDir = true;
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 80 443 ];
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  security.pam.enableSSHAgentAuth = true;

  services.redshift = {
    enable = true;
    brightness.night = "0.8";
    temperature.night = 3500;
    latitude = "47.5";
    longitude = "8.75";
  };

  services.pages = {
    enable = true;
    sources = import ./modules/pages/docs.nix pkgs;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.c544ppd ];
  };

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;

    xkbVariant = "neo";

    desktopManager = {
      xterm.enable = false;
      default = "none";
    };
    windowManager = {
      awesome.enable = false;
      stumpwm.enable = true;
      default = "stumpwm";
    };
    displayManager = {
      sessionCommands = ''
        export JAVA_HOME=${pkgs.jdk}/lib/openjdk
        export JDK_HOME=${pkgs.jdk}/lib/openjdk
        ${pkgs.neomodmap}/bin/neomodmap.sh on

        gpg-connect-agent /bye
        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gnupg/S.gpg-agent.ssh"
      '';
    };
  };

  nixpkgs = {
    config = {
      firefox = {
        icedtea = true;
      };
      chromium = {
        icedtea = true;
      };
    };
  };

  system.activationScripts = {
    gpgAgentOptions = let cacheTime = builtins.toString (4 * 60 * 60); in ''
      cat > /home/eike/.gnupg/gpg-agent.conf <<-"EOF"
      enable-ssh-support
      default-cache-ttl ${cacheTime}
      max-cache-ttl ${cacheTime}
      default-cache-ttl-ssh ${cacheTime}
      max-cache-ttl-ssh ${cacheTime}
      allow-emacs-pinentry
      pinentry-program "${pkgs.pinentry}/bin/pinentry-gtk-2"
      EOF
    '';
  };

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    fonts = with pkgs; [
      #corefonts #unfree
      inconsolata
      source-code-pro
      dejavu_fonts
      ttf_bitstream_vera
      terminus_font
    ];
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
    exiv2
    easytag
    ffmpeg
    calibre

  # x-window
    xlibs.xrandr
    xlibs.xmodmap
    xlibs.xwd
    xlibs.xdpyinfo
    xsel
    xorg.xwininfo
    xfce.terminal
    xclip
    autorandr
    i3lock

  # web/email
    firefoxWrapper
    conkerorWrapper
    surfraw
    mu
    offlineimap

  # devel
    sbcl
    python
    scala
    sbt
    clojure
    leiningen
    jdk
    maven
    ant
    idea.idea-community
    silver-searcher
    global
    visualvm
    tex
    R
    cask
    coursier

  # other tools
    zathura
    ghostscript
    libreoffice
    sqliteman
    pandoc
    youtube-dl
    mediathekview
    sig
    python27Packages.pygments
    drip
    neomodmap
    recoll
    recordmydesktop
    aspell
    aspellDicts.en
    aspellDicts.de
  ];
}
