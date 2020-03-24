{ config, pkgs, ... }:

{
  imports =
    [ ./hw-n76.nix
      ../../modules/accounts.nix
      ../../modules/docker.nix
      ../../modules/fonts.nix
      ../../modules/ids.nix
      ../../modules/java.nix
      ../../modules/latex.nix
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/region-neo.nix
      ../../modules/software.nix
      ../../modules/user.nix
      ../../modules/vbox-host.nix
      ./mpd.nix
      ./fileserver.nix
      ./hinclient.nix
      ./vpn.nix
      ./printer.nix
    ] ++
    (import ../../pkgs/modules.nix);


  boot = {
    kernelPackages = pkgs.linuxPackages_5_4;
    cleanTmpDir = true;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices = {
      crootfs = { device = "/dev/nvme0n1p1"; preLVM = true; };
    };
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

  software.extra = with pkgs;
  [
    ansible
    libreoffice
    mongodb
    mongodb-tools
    nodePackages.grunt-cli
    nodePackages.gulp
    slack
    vagrant
    yarn
    teams
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
    };
    windowManager = {
      awesome.enable = false;
      stumpwm.enable = true;
    };
    displayManager = {
      defaultSession = "none+stumpwm";
      sessionCommands = ''
        ${pkgs.compton}/bin/compton &
        ${pkgs.xlibs.xrandr}/bin/xrandr --dpi 110
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

  services.davmail = {
    enable = true;
    url = "https://${config.accounts."bluecare/login".mailhost}/owa";
    config = {
      davmail.server = true;
      davmail.mode = "EWS";
      davmail.caldavPort = 1080;
      davmail.imapPort = 1143;
      davmail.smtpPort = 1025;
      davmail.disableUpdateCheck = true;
      davmail.logFilePath = "/var/log/davmail/davmail.log";
      davmail.logFileSize = "1MB";
      log4j.logger.davmail = "WARN";
      log4j.logger.httpclient.wire = "WARN";
      log4j.logger.org.apache.commons.httpclient = "WARN";
      log4j.rootLogger = "WARN";
    };
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
  system.stateVersion = "19.09"; # Did you read the comment?

}
