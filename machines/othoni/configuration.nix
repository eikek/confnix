{ config, pkgs, ... }:
let mykey = builtins.readFile <sshpubkey>; in
{
  imports =
    [ ./hw-othoni.nix
      ../../modules/accounts.nix
      ../../modules/docker.nix
      ../../modules/fonts.nix
      ../../modules/ids.nix
      ../../modules/latex.nix
      ../../modules/java.nix
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/region-neo.nix
      ../../modules/software.nix
      ../../modules/user.nix
      ../../modules/vbox-host.nix
    ] ++
    (import ../../pkgs/modules.nix);

  users.users.oth = {
    name = "oth";
    isNormalUser = true;
    uid = 1002;
    createHome = true;
    home = "/home/oth";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" "networkmanager" ];
  };

  boot = {
#    kernelPackages = pkgs.linuxPackages_5_4;
    cleanTmpDir = true;
    initrd.luks.devices = {
      crootfs = { device = "/dev/sda1"; preLVM = true; };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  powerManagement = {
    enable = true;
  };

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

    videoDrivers = [ "radeon" ];

    desktopManager = {
      xterm.enable = false;
      xfce.enable = false;
      gnome3.enable = true;
      plasma5.enable = false;
    };
    windowManager = {
      stumpwm.enable = false;
    };
    displayManager = {
      lightdm.autoLogin = {
        enable = true;
        user = "oth";
      };
      defaultSession = "gnome";
      #lightdm.enable = true; //the default
      sessionCommands = ''
        ${pkgs.compton}/bin/compton &

        xrandr --dpi 200
        echo 'Xft.dpi: 200' | xrdb -merge
      '';
    };
  };

  users.groups.kvm = {
    members = [ "eike" "oth" ];
  };

  networking = {
    hostName = "othoni";
    wireless = {
      enable = false; #networkmanager is true
    };
    useDHCP = false; # networkmanager is true
    firewall.allowedTCPPorts = [ 4443 8000 ];
    firewall.allowedUDPPorts = [ 10000 ];

    # nat = {
    #   enable = true;
    #   externalInterface = "enp109s0f1";
    #   internalInterfaces = [ "ve-+" ];
    # };

   # localCommands = ''
   #   ${pkgs.vde2}/bin/vde_switch -tap tap0 -mod 660 -group kvm -daemon
   #   ip addr add 10.0.2.1/24 dev tap0
   #   ip link set dev tap0 up
   #   ${pkgs.procps}/sbin/sysctl -w net.ipv4.ip_forward=1
   #   ${pkgs.iptables}/sbin/iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -j MASQUERADE
   # '';
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
    bindPort = 8011;
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
  environment.systemPackages = with pkgs; [
    okular
    gnome3.evince
    calibre
    gnome3.gnome-calendar
    gnome3.gnome-clocks
    gnome3.gnome-power-manager
    gnome3.gnome-weather
    gnome3.gnome-themes-standard
    gnome3.shotwell
    vlc
    sambaFull
    smbclient
    libreoffice
  ];

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


  system.activationScripts = {
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
