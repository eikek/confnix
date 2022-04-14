{ config, pkgs, ... }:
let
  printer = import ../../modules/printer.nix;
in
{
  imports =
    [ ./hw-n76.nix
      ../../modules/accounts.nix
      ../../modules/bluetooth.nix
      ../../modules/docker.nix
      ../../modules/emacs.nix
      ../../modules/flakes.nix
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
      ../../modules/xserver.nix
#      ./mpd.nix
      ./fileserver.nix
      ./hinclient.nix
      ./vpn.nix
    ] ++
    (import ../../pkgs/modules.nix);


  boot = {
    kernelPackages = pkgs.linuxPackages_5_12;
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
    openshift
    slack
    vagrant
    yarn
    teams
    zoom-us
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
    displayManager.sessionCommands = ''
      if [ $(xrandr --listmonitors | grep "^ .*3840/.*x2160/.*" | wc -l) -eq 1 ]; then
        xrandr --dpi 140
        echo 'Xft.dpi: 140' | xrdb -merge
      else
        xrandr --dpi 110
        echo 'Xft.dpi: 110' | xrdb -merge
      fi
    '';
  };

  services.webact = {
    app-name = "Webact " + config.networking.hostName;
    enable = true;
    userService = true;
    extra-packages = [ pkgs.bash pkgs.ammonite pkgs.coreutils pkgs.elvish ];
    extra-path = [ "/home/eike/bin" "/run/current-system/sw/bin" ];
    env = {
      "DISPLAY" = ":0";
    };
    bind.address = "localhost";
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
  containers.dbsolr =
  { config = import ../../modules/devdb-solr.nix;
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

  # containers.docspell =
  #   { config = import ../../modules/docspell.nix;
  #     autoStart = false;
  #     privateNetwork = true;
  #     hostAddress = "10.231.2.1";
  #     localAddress = "10.231.2.3";
  #   };

  # services.docspell-consumedir = {
  #   enable = true;
  #   integration-endpoint = {
  #     enabled = true;
  #     header = "Docspell-Integration:test123";
  #   };
  #   verbose = true;
  #   distinct = true;
  #   deleteFiles = true;
  #   watchDirs = ["/home/docspell-local"];
  #   urls = ["http://docspell:7880/api/v1/open/integration/item"];
  # };

  networking.extraHosts = ''
    10.231.2.2 devmail
    10.231.2.3 docspell
  '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}
