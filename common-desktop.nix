{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  time.timeZone = "Europe/Berlin";

  i18n = {
    consoleKeyMap = pkgs.lib.mkForce "${pkgs.neomodmap}/share/keymaps/i386/neo/neo.map";
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

  # clean /tmp regularly
  services.cron.systemCronJobs = [
    "0 0,4,8,12,16,20 * * * root find /tmp -atime +28 -delete"
  ];

  services.pages = {
    enable = true;
    sources = import ./modules/pages/docs.nix pkgs;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.c544ppd ];
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
    startGnuPGAgent = true;
    displayManager = {
      sessionCommands = ''
        export JAVA_HOME=${pkgs.jdk}/lib/openjdk
        export JDK_HOME=${pkgs.jdk}/lib/openjdk
        ${pkgs.neomodmap}/bin/neomodmap.sh on
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

  system.activationScripts = {
    gpgAgentOptions = let cacheTime = builtins.toString (4 * 60 * 60); in ''
      cat > /home/eike/.gnupg/gpg-agent.conf <<-"EOF"
      enable-ssh-support
      default-cache-ttl ${cacheTime}
      max-cache-ttl ${cacheTime}
      default-cache-ttl-ssh ${cacheTime}
      max-cache-ttl-ssh ${cacheTime}
      pinentry-program "${pkgs.pinentry}/bin/pinentry-gtk-2"
      EOF
    '';
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

  environment.systemPackages = with pkgs ; [
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

  # images
    feh
    viewnior
    imagemagick
    jhead
    libjpeg
    gimp

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
    soundkonverter
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
    xfce.terminal
    compton
    stumpwm
    xclip
    autorandr
    i3lock

  # web/email
    firefoxWrapper
    conkerorWrapper
    surfraw
    mu
    offlineimap
    chromium

  # devel
    subversion
    lua
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

  # tex
  # see https://nixos.org/wiki/TexLive_HOWTO
    (pkgs.texLiveAggregationFun { paths = [
       pkgs.texLive
       pkgs.texLiveExtra
       pkgs.texLiveBeamer
       pkgs.texLiveModerncv
       pkgs.texLiveModerntimeline
       pkgs.texLiveContext
       pkgs.texLiveCMSuper
       pkgs.texLiveLatexXColor
       pkgs.texLivePGF
       pkgs.lmodern
    ]; })

  # other tools
    html2text
    html2textpy
    zathura
    ghostscript
    wireshark
    libreoffice
    sqliteman
    pandoc
    youtube-dl
    mediathekview
    sig
    python27Packages.pygments
    drip
    neomodmap
  ];
}
