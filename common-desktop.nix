{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  users.extraUsers.eike.extraGroups = [ "vboxusers" ];

  time.timeZone = "Europe/Berlin";

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # needed for the `user` option below
  security.setuidPrograms = [ "mount.cifs" ];

  # clean /tmp regularly
  services.cron.systemCronJobs = [
    "0 0,4,8,12,16,20 * * * root find /tmp -atime +28 -delete"
  ];

  fileSystems = builtins.listToAttrs (map (mp:
    { name = "/mnt/nas/" + mp;
      value = {
        device = "//nas/" + mp;
        fsType = "cifs";
        options = "noauto,user,username=eike,password=eike,uid=1000,gid=100";
        noCheck = true;
      };
    }) ["backups" "dokumente" "downloads" "home" "music" "photo" "safe" "video"]);

  services.virtualboxHost.enable = true;
  services.virtualboxHost.enableHardening = true;

  services.pages = {
    enable = true;
    sources = import ./modules/pages/docs.nix pkgs;
  };

  services.mongodb = {
    enable = true;
    extraConfig = ''
      nojournal = true
      '';
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.c544ppd ];
  };

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;

    desktopManager = {
      xterm.enable = false;
      default = "none";
    };
    windowManager = {
      awesome.enable = true;
      stumpwm.enable = true;  #unstable
      default = "awesome";
    };
    startGnuPGAgent = true;
    displayManager = {
      sessionCommands = ''
        export JAVA_HOME=${pkgs.jdk}
        export JDK_HOME=${pkgs.jdk}
        setxkbmap -layout de
        xmodmap -e "keycode 66 = Shift_L"
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
    automake
    gnumake
    autoconf
    wicd
    which

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
    libav
    libtheora
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
    stumpwmContrib
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
    asdf
    python
    scala
    sbt
    clojure
    leiningen
    jdk
    maven
    ant
    idea.idea-community
    nodejs
    mozart
    haskellPackages_ghc783_no_profiling.ghcPlain

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
    gitg
    zathura
    xpdf
    ghostscript
    wireshark
    libreoffice
    sqliteman
    unison
    pandoc
    youtube-dl
    mediathekview
    sig
    python27Packages.pygments
    drip
  ];
}
