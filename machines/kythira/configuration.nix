{ config, pkgs, ... }:
let mykey = builtins.readFile <sshpubkey>; in
{
  imports =
    [ ./hw-kythira.nix
      ../../modules/accounts.nix
      ../../modules/docker.nix
      ../../modules/ids.nix
      ../../modules/latex.nix
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/region-neo.nix
      ../../modules/user.nix
      ../../modules/vbox-host.nix
    ] ++
    (import ../../pkgs/modules.nix);

  boot = {
    cleanTmpDir = true;
    initrd.luks.devices = [
      { device = "/dev/vgroot/root"; name = "rootfs"; preLVM = false; }
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  powerManagement = {
    enable = true;
  };

  fileSystems =
  let
    mounts = {
      "/mnt/data" = {
        device = "/dev/disk/by-label/data";
        fsType = "xfs";
        options = ["noauto" "user" "rw" "exec" "suid" "async"];
        noCheck = true;
      };
    };
  in mounts // (builtins.listToAttrs (map (mp:
    { name = "/mnt/nas/" + mp;
      value = {
        device = "//files.home/" + mp;
        fsType = "cifs";
        options = ["noauto" "user" "username=eike" "password=eike" "uid=1000" "gid=100" "vers=2.0" ];
        noCheck = true;
      };
    }) ["data" "eike"]));

  virtualisation.virtualbox.host.enableExtensionPack = true;

  security = {
    pam.enableSSHAgentAuth = true;
    wrappers."mount.cifs".source = "${pkgs.cifs-utils}/bin/mount.cifs";
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
    libinput.enable = true;
    xkbVariant = "neo";

    videoDrivers = [ "nvidia" ];

    desktopManager = {
      xterm.enable = false;
      default = "none";
    };
    windowManager = {
      stumpwm.enable = true;
      default = "stumpwm";
    };
    displayManager = {
      #lightdm.enable = true; //the default
      sessionCommands = ''
        export JAVA_HOME=${pkgs.jdk}/lib/openjdk
        export JDK_HOME=${pkgs.jdk}/lib/openjdk
        ${pkgs.compton}/bin/compton &

        gpg-connect-agent /bye
        unset SSH_AGENT_PID
        export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gnupg/S.gpg-agent.ssh"

        if [ $(xrandr --listmonitors | grep "^ .*3840/.*x2160/.*" | wc -l) -eq 2 ]; then
          xrandr --output DP-0 --off
          xrandr --dpi 140
        else
          xrandr --dpi 220
          echo 'Xft.dpi: 220' | xrdb -merge
        fi
      '';
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      dpi = 140;
    };
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

  users.groups.kvm = {
    members = [ "eike" ];
  };

  networking = {
    hostName = "kythira";
    wireless = {
      enable = true;
    };
    useDHCP = true;

    nat = {
      enable = true;
      externalInterface = "enp109s0f1";
      internalInterfaces = [ "ve-+" ];
    };

   localCommands = ''
     ${pkgs.vde2}/bin/vde_switch -tap tap0 -mod 660 -group kvm -daemon
     ip addr add 10.0.2.1/24 dev tap0
     ip link set dev tap0 up
     ${pkgs.procps}/sbin/sysctl -w net.ipv4.ip_forward=1
     ${pkgs.iptables}/sbin/iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -j MASQUERADE
   '';
  };

  # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "lock"
  services.logind.lidSwitch = "ignore";

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
          localDomains = [ "devmail.org" "test.com" ];
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

  environment.pathsToLink = [ "/" ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    sshServe.enable = true;
    sshServe.keys = [ mykey ];
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs;
  [
  # base
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
    firefox-esr
    mu
    offlineimap
    qutebrowser

  # devel
    R
    ammonite-repl
    ant
    clojure
    elmPackages.elm
    global
    idea.idea-community
    jdk
    leiningen
    mariadb
    maven
    postgresql_11
    python
    sbcl
    sbt
    scala
    silver-searcher
    visualvm

  # other tools
    drip
    ghostscript
    pandoc
    sqliteman
    tesseract_4
    unpaper
    youtube-dl
    zathura
    docspell.tools

  ];

  system.activationScripts = {
    kworkerbug = ''
      echo "disable" > /sys/firmware/acpi/interrupts/gpe6F || true
    '';
  };

}
