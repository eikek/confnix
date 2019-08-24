{ config, pkgs, ... }:
let mykey = builtins.readFile /home/eike/.ssh/id_rsa.pub; in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-kythira.nix
      ../../common-desktop.nix
      ../../env-home.nix
      ../../env-vbox.nix
    ];

  boot = {
    initrd.luks.devices = [
      { device = "/dev/vgroot/root"; name = "rootfs"; preLVM = false; }
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/mnt/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "xfs";
      options = ["noauto" "user" "rw" "exec" "suid" "async"];
      noCheck = true;
    };
  };

  fonts.fontconfig = {
    dpi = 140;
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
    userService = true;
    baseDir = "/home/eike/.webact";
    extraPackages = [ pkgs.bash pkgs.ammonite pkgs.coreutils pkgs.elvish ];
    extraPaths = [ "/home/eike/bin" "/run/current-system/sw/bin" ];
    extraEnv = {
      "DISPLAY" = ":0";
    };
    bindHost = "localhost";
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      accelFactor = "0.001";
      buttonsMap = [ 1 3 2 ];
    };

    displayManager = {
      sessionCommands = ''
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

  environment.systemPackages = with pkgs; [
    mariadb postgresql_11 wpa_supplicant unpaper
  ];

  system.activationScripts = {
    kworkerbug = ''
      echo "disable" > /sys/firmware/acpi/interrupts/gpe6F || true
    '';
  };

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
}
