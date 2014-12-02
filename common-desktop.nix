{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    <nixpkgs/nixos/modules/programs/virtualbox.nix>
  ];

  users.extraUsers.eike.extraGroups = [ "vboxusers" ];

  time.timeZone = "Europe/Berlin";

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  fileSystems = builtins.listToAttrs (map (mp:
    { name = "/mnt/nas/" + mp;
      value = {
        device = "//nas/" + mp;
        fsType = "cifs";
        options = "noauto,username=eike,password=eike,uid=1000,gid=100";
        noCheck = true;
      };
    }) ["backups" "dokumente" "downloads" "home" "music" "photo" "safe" "video"]);


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
    startGnuPGAgent = false;
  };

  fonts = {
    enableFontConfig = true;
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

  # x-window
    xlibs.xrandr
    xlibs.xmodmap
    xlibs.twm
    xlibs.xwd
    xfce.terminal
    compton
    stumpwm
    xclip
    autorandr
    i3lock
    gnome.metacity

  # web/email
    firefox
    conkerorWrapper
    surf
    mu
    offlineimap

  # devel
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
       ]; })

  # other tools
    html2text
    html2textpy
    gitg
    zathura
    xpdf
    ghostscript
    wireshark
    lxdvdrip
    dvdauthor
    libav
    libtheora
    libreoffice
    sqliteman
  ];
}
