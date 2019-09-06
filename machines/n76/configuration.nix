{ config, pkgs, ... }:

{
  imports =
    [ ./hw-n76.nix
      ../../modules/accounts.nix
      ../../modules/docker.nix
      ../../modules/ids.nix
      ../../modules/latex.nix
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/region-neo.nix
      ../../modules/user.nix
      ../../modules/vbox-host.nix
      ./mpd.nix
      ./fileserver.nix
      ./hinclient.nix
      ./vpn.nix
    ] ++
    (import ../../pkgs/modules.nix);


  boot = {
    cleanTmpDir = true;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices = [
      { device = "/dev/nvme0n1p1"; name = "crootfs"; preLVM = true; }
    ];
  };

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.openFirewall = true;

  networking = {
    hostName = "n76"; 
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 9000 ];
    };
    wireless = {
      enable = true;
    };
    useDHCP = true;
  };

  nix.maxJobs = pkgs.lib.mkOverride 20 6;

  users.groups.kvm = {
    members = [ "eike" ];
  };

  environment.systemPackages = with pkgs;
  [
    cifs_utils
    direnv
    fzf
    git-crypt
    gitAndTools.gitFull
    iptables
    jq
    mr
    nix-prefetch-scripts
    nixops
    openssl
    pass
    pinentry
    recutils
    rlwrap
    sqlite
    tig
    tmuxinator
    tree
    which
    wpa_supplicant
    zsh

  # images
    feh
    gimp
    gnuplot
    graphviz
    imagemagick
    jhead
    libjpeg
    plantuml
    viewnior

  # multimedia
    alsaUtils
    cdparanoia
    ffmpeg
    flac
    mediainfo
    mplayer
    mpv
    sox
    vlc
    vorbisTools

  # x-window
    alacritty
    autorandr
    i3lock
    i3lock-fancy
    stumpish
    xclip
    xfce.terminal
    xlibs.xdpyinfo
    xlibs.xmodmap
    xlibs.xrandr
    xlibs.xwd
    xorg.xwininfo
    xsel

  # web/email
    chromium
    firefox
    mu
    offlineimap
    qutebrowser

  # devel
    R
    ammonite-repl
    ansible
    clojure
    elmPackages.elm
    git-crypt
    gitAndTools.gitFull
    global
    guile
    idea.idea-community
    jdk
    jq
    leiningen
    mariadb
    maven
    mongodb
    mongodb-tools
    nodePackages.grunt-cli
    nodePackages.gulp
    postgresql_11
    python
    sbcl
    sbt
    scala
    silver-searcher
    visualvm

  # other tools
    direnv
    drip
    ghostscript
    iptables
    libreoffice
    mr
    nix-prefetch-scripts
    nixops
    openssl
    pass
    peek
    recutils
    rlwrap
    slack
    tesseract_4
    unpaper
    vagrant
    yarn
    zathura
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
#      packageOverrides = import ./pkgs;
    };
  };

  powerManagement = {
    enable = true;
#    cpuFreqGovernor = "ondemand";
  };

  security.pam.enableSSHAgentAuth = true;

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    enable = true;
    autorun = true;
    layout = "de";
    exportConfiguration = true;
    libinput.enable = true;
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
        ${pkgs.compton}/bin/compton &

        ${pkgs.xlibs.xrandr}/bin/xrandr --dpi 110

        gpg-connect-agent /bye
        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gnupg/S.gpg-agent.ssh"
      '';
    };
  };

  services.webact = {
    appName = "Webact " + config.networking.hostName;
    enable = true;
    userService = true;
    baseDir = "/home/eike/.webact";
    extraPackages = [ pkgs.bash pkgs.ammonite pkgs.coreutils pkgs.elvish ];
    extraPaths = [ "/home/eike/bin" "/run/current-system/sw/bin" ];
    extraEnv = {
      "DISPLAY" = ":0";
    };
    bindHost = "localhost";
  };

  services.ntp = {
    enable = true;
    servers = [ "192.168.10.1" ];
  };

  fonts.fonts = with pkgs; [
    corefonts #unfree
  ];

  containers.dbmysql =
  { config = import ../../modules/devdb-mariadb.nix;
    autoStart = false;
  };
  containers.dbpostgres =
  { config = import ../../modules/devdb-postgres.nix;
    autoStart = false;
  };
  containers.devmail =
  { config = {config ,pkgs, ... }:
      { imports = [ ../../modules/devmail.nix ];
        services.devmail = {
          enable = true;
          primaryHostname = "devmail";
          localDomains = [ "hin.ch" "test.com" ];
        };
      };
    privateNetwork = true;
    hostAddress = "10.231.2.1";
    localAddress = "10.231.2.2";
    autoStart = false;
  };
  networking.extraHosts = ''
    10.231.2.2 devmail
  '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
