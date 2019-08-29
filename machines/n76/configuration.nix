{ config, pkgs, ... }:
let
 serverpass = if (builtins.tryEval <serverpass>).success then
   builtins.readFile <serverpass>
   else builtins.throw ''Please specify a file that contains the
     password to mount the fileserver and add it to the NIX_PATH
     variable with key "serverpass".
   '' ;
  hinpass = let val = builtins.tryEval <hinpass>; in
   if (val.success) then builtins.toPath val.value
   else builtins.throw ''Please specify a file that contains the
     password to mount the fileserver and add it to the NIX_PATH
     variable with key "hinpass".
  '' ;
  fileServer = "bluecare-s54";
in
{
  imports =
    [ ./hw-n76.nix ./mpd.nix ] ++
    (import ../../modules/all.nix) ++
    (import ../../pkgs/modules.nix);

  boot = {
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
    tesseract_4
    mongodb
    mongodb-tools
    ansible
    nodePackages.grunt-cli
    nodePackages.gulp
    yarn
    vagrant
    libreoffice
    slack
    peek
    gitAndTools.gitFull
    git-crypt
    tig
    zsh
    pass
    mr
    rlwrap
    sqlite
    nix-prefetch-scripts
    guile
    openssl
    which
    recutils
    tmuxinator
    direnv
    tree
    jq
    elvish
    wpa_supplicant
    iptables
    nixops

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
    mpv
    vlc
    cdparanoia
    sox
    flac
    vorbisTools
    ffmpeg
    alsaUtils
    mediainfo
#    calibre doesn't build atm

  # x-window
    xlibs.xrandr
    xlibs.xmodmap
    xlibs.xwd
    xlibs.xdpyinfo
    xsel
    xorg.xwininfo
    xfce.terminal
    alacritty
    xclip
    autorandr
    i3lock
    i3lock-fancy
    stumpish

  # web/email
    firefox
    qutebrowser
    chromium
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
    idea.idea-community
    silver-searcher
    global
    visualvm
    R
    ammonite-repl
    elmPackages.elm

  # other tools
    zathura
    ghostscript
    drip
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

  services.redshift = {
    enable = true;
    brightness.night = "0.8";
    temperature.night = 3500;
    latitude = "47.5";
    longitude = "8.75";
  };

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


  services.ntp = {
    enable = true;
    servers = [ "192.168.10.1" ];
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  fonts.fonts = with pkgs; [
    corefonts #unfree
  ];

  containers.dbmysql =
  { config = { config, pkgs, ... }:
    { services.mysql = {
        enable = true;
        package = pkgs.mariadb;
        initialScript = pkgs.writeText "devmysql-init.sql" ''
          CREATE USER IF NOT EXISTS 'dev' IDENTIFIED BY 'dev';
          GRANT ALL ON *.* TO 'dev'@'%';
        '';
        extraOptions = ''
          skip-networking=0
          skip-bind-address
       '';
      };
    };
    autoStart = false;
  };

  containers.dbpostgres =
  { config = { config, pkgs, ... }:
    { services.postgresql =
      let
        pginit = pkgs.writeText "pginit.sql" ''
          CREATE USER dev WITH PASSWORD 'dev' LOGIN CREATEDB;
          GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dev;
          GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dev;
        '';
      in {
        enable = true;
        package = pkgs.postgresql_11;
        enableTCPIP = true;
        initialScript = pginit;
        port = 5432;
      };
    };
    autoStart = false;
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

  services.openvpn.servers = {
    officeVPN = {
      config = " config /root/openvpn/vpfwblue.bluecare.ch.ovpn ";
      autoStart = false;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
