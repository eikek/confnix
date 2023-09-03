{ config, pkgs, ... }:
let
  mykey = builtins.readFile <sshpubkey>;
  printer = import ../../modules/printer.nix;
  usermod = import ../../modules/user.nix "eike";
  dockermod = import ../../modules/docker.nix [ "eike" "sdsc" ];
in
{
  imports =
    [ ./hw-kalamos.nix
      ./vpn.nix
      ./work.nix
      ../../modules/accounts.nix
      ../../modules/androiddev.nix
      ../../modules/bluetooth.nix
      ../../modules/dsc-watch.nix
      ../../modules/emacs.nix
      ../../modules/ergodox.nix
      ../../modules/flakes.nix
      ../../modules/fonts.nix
      ../../modules/ids.nix
      ../../modules/java.nix
      ../../modules/latex.nix
#      ../../modules/localssl
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/region-neo.nix
      ../../modules/software.nix
      ../../modules/vbox-host.nix
      ../../modules/xserver.nix
      <monitor>
      printer.home
      usermod
      dockermod
    ] ++
    (import ../../pkgs/modules.nix);

  boot = {
    tmp.cleanOnBoot = true;
    initrd.luks.devices = {
      crootfs = { device = "/dev/nvme0n1p1"; preLVM = true; };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "ondemand";
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

#Requires recompile of virtualbox
#  virtualisation.virtualbox.host.enableExtensionPack = true;

  security = {
    pam.enableSSHAgentAuth = true;
    #wrappers."mount.cifs".source = "${pkgs.cifs-utils}/bin/mount.cifs";
  };

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  # services.xserver = {
  #   videoDrivers = [ "nvidia" ];
  #   # displayManager.sessionCommands = ''
  #   # '';
  # };

  users.groups.kvm = {
    members = [ "eike" ];
  };

  networking = {
    hostName = "kalamos";
    wireless = {
      enable = true;
    };
    useDHCP = true;

    nat = {
      enable = true;
      externalInterface = "enp2s0";
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


  services.udisks2 = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
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
    bind = {
      address = "localhost";
      port = 8011;
    };
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
    permittedInsecurePackages = [
      "python2.7-certifi-2021.10.8" #???
      "python2.7-pyjwt-1.7.1" #???
    ];
  };

  nix = {
    sshServe.enable = true;
    sshServe.keys = [ mykey ];
  };

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05"; # Did you read the comment?

}
