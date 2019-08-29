{ config, pkgs, ... }:
let mykey = builtins.readFile <sshpubkey>; in
{
  imports =
    [ ./hw-kythira.nix ] ++
    (import ../../modules/all.nix) ++
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

  services.redshift = {
    enable = true;
    brightness.night = "0.8";
    temperature.night = 3500;
    latitude = "47.5";
    longitude = "8.75";
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
    appName = "Webact Kythira";
    enable = true;
    runAs = "eike";
    baseDir = "/home/eike/.webact";
    extraPackages = [ pkgs.bash pkgs.ammonite pkgs.coreutils pkgs.elvish ];
    extraPaths = [ "/home/eike/bin" "/run/current-system/sw/bin" ];
    extraEnv = {
      "DISPLAY" = ":0";
    };
    bindHost = "localhost";
  };


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
    binutils
    file
    gitAndTools.gitFull
    git-crypt
    tig
    zsh
    pass
    mr
    rlwrap
    sqlite
    nix-prefetch-scripts
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
    cifs_utils
    aumix
    nixops
    emacs
    gnupg

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
    ant
    idea.idea-community
    silver-searcher
    global
    visualvm
    tex
    R
    ammonite-repl
    elmPackages.elm
    mariadb
    postgresql_11

  # other tools
    unpaper
    zathura
    ghostscript
    sqliteman
    pandoc
    youtube-dl
    drip
    tesseract_4

  ];

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
    kworkerbug = ''
      echo "disable" > /sys/firmware/acpi/interrupts/gpe6F || true
    '';
  };

}
