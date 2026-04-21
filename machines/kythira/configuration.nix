{ config, pkgs, ... }:
let
  sshkeys = import ../../secrets/ssh-keys.nix;
  usermod = import ../../modules/user.nix { username = "eike"; };
  dockermod = import ../../modules/docker.nix [ "eike" ];
in
{
  imports =
    [
      ./hw-kythira.nix
      ../../modules/bluetooth.nix
      ../../modules/emacs.nix
      ../../modules/flakes.nix
      ../../modules/fonts.nix
      ../../modules/ids.nix
      ../../modules/java.nix
      ../../modules/packages.nix
      ../../modules/region-neo.nix
      ../../modules/xserver.nix
      usermod
      dockermod
      ./llm.nix
    ] ++
    (import ../../pkgs/modules.nix);

  age.secrets.eike.file = ../../secrets/eike.age;
  users.users.eike.hashedPasswordFile = config.age.secrets.eike.path;

  boot = {
    tmp.cleanOnBoot = true;
    initrd.luks.devices = {
      crootfs = {
        device = "/dev/nvme0n1p1";
        preLVM = true;
      };
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
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "ondemand";
  };

  fileSystems =
    {
      "/mnt/data1" = {
        device = "/dev/disk/by-label/data1";
        fsType = "ext4";
        options = [ "noauto" "user" "rw" "exec" "suid" "async" ];
        noCheck = true;
      };
    };

  security = {
    pam.sshAgentAuth.enable = true;
    wrappers = {
      "mount.cifs" = {
        source = "${pkgs.cifs-utils}/bin/mount.cifs";
        owner = "root";
        group = "root";
      };
    };
  };

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
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
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  environment.systemPackages = with pkgs;
    [
      mdadm

      ffmpeg
      flac
      mediainfo
      mpv

    ];

  environment.pathsToLink = [ "/" ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true; #needs unfree

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
    };
  };


  # system.activationScripts = {
  #   kworkerbug = ''
  #     echo "disable" > /sys/firmware/acpi/interrupts/gpe6F || true
  #   '';
  # };

  system.stateVersion = "25.11"; # Did you read the comment?
}
