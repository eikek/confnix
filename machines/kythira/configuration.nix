{ config, pkgs, ... }:
let
  mykey = builtins.readFile <sshpubkey>;
  printer = import ../../modules/printer.nix;
  usermod = import ../../modules/user.nix "eike";
  dockermod = import ../../modules/docker.nix [ "eike" "sdsc" ];
in
{
  imports =
    [
      ./hw-kythira.nix
      ../../modules/accounts.nix
      ../../modules/androiddev.nix
      ../../modules/bluetooth.nix
      ../../modules/emacs.nix
      ../../modules/ergodox.nix
      ../../modules/flakes.nix
      ../../modules/fonts.nix
      ../../modules/ids.nix
      ../../modules/java.nix
      ../../modules/latex.nix
      ../../modules/packages.nix
      ../../modules/redshift.nix
      ../../modules/region-neo.nix
      ../../modules/software.nix
      ../../modules/vbox-host.nix
      ../../modules/xserver.nix
      ./vpn.nix
      ./keybase.nix
      usermod
      dockermod
    ] ++
    (import ../../pkgs/modules.nix);

  boot = {
    #    kernelPackages = pkgs.linuxPackages_5_14;
    tmp.cleanOnBoot = true;
    initrd.luks.devices = {
      rootfs = { device = "/dev/vgroot/root"; preLVM = false; };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
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
          options = [ "noauto" "user" "rw" "exec" "suid" "async" ];
          noCheck = true;
        };
      };
    in
    mounts // (builtins.listToAttrs (map
      (mp:
        {
          name = "/mnt/nas/" + mp;
          value = {
            device = "//files.home/" + mp;
            fsType = "cifs";
            options = [ "noauto" "user" "username=eike" "password=eike" "uid=1000" "gid=100" "vers=2.0" ];
            noCheck = true;
          };
        }) [ "data" "eike" ]));

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

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    displayManager.sessionCommands = ''
      if [ $(xrandr --listmonitors | grep "^ .*3840" | wc -l) -eq 2 ]; then
        xrandr --dpi 120
        echo 'Xft.dpi: 120' | xrdb -merge
      else
        xrandr --dpi 220
        echo 'Xft.dpi: 220' | xrdb -merge
      fi
      ${pkgs.stalonetray}/bin/stalonetray &
    '';
  };

  users.groups.kvm = {
    members = [ "eike" ];
  };

  networking = {
    hostName = "kythira";
    wireless = {
      enable = true;
      interfaces = [ "wlp110s0" ];
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

  software.extra = with pkgs;
    [
      libreoffice
      slack
      gopass
      python3Packages.pip
      coursier
    ];

  # containers.dbpostgres =
  # { config = import ../../modules/devdb-postgres.nix;
  #   autoStart = false;
  # };
  # containers.devmail =
  # { config = {config ,pkgs, ... }:
  #     { imports = [ ../../modules/devmail.nix ];
  #       services.devmail = {
  #         enable = true;
  #         primaryHostname = "devmail";
  #         localDomains = [ "devmail.org" "test.com" ];
  #       };
  #     };
  #   privateNetwork = true;
  #   hostAddress = "10.231.2.1";
  #   localAddress = "10.231.2.2";
  #   autoStart = false;
  # };
  # networking.extraHosts = ''
  #   10.231.2.2 devmail
  # '';

  environment.pathsToLink = [ "/" ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true; #needs unfree
    opengl.driSupport32Bit = true;
  };


  # system.activationScripts = {
  #   kworkerbug = ''
  #     echo "disable" > /sys/firmware/acpi/interrupts/gpe6F || true
  #   '';
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05"; # Did you read the comment?

}
