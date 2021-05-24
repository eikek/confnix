{ config, pkgs, ... }:
let
  mykey = builtins.readFile <sshpubkey>;
  printer = import ../../modules/printer.nix;
in
{
  imports =
    [ ./hw-kalamos.nix
      ./nvidia-offload.nix
      ../../modules/accounts.nix
      ../../modules/androiddev.nix
      ../../modules/bluetooth.nix
      ../../modules/consumedir-main.nix
      ../../modules/docker.nix
      ../../modules/emacs.nix
      ../../modules/ergodox.nix
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
      printer.home
    ] ++
    (import ../../pkgs/modules.nix);


  services.xserver = {
    xkbVariant = lib.mkForce "";
    desktopManager = {
      gnome3 = {
        enable = true;
      };
    };
  };
  program.gnupg.agent.pinentryFlavor = "gnome3"

  users.users.linda = {
    name = "linda";
    isNormalUser = true;
    uid = 1001;
    createHome = true;
    home = "/home/linda";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "disk" "adm" "systemd-journal" "vboxusers" "adbusers" ];
  };


  services.openssh.enable = true;

  boot = {
    #    kernelPackages = pkgs.linuxPackages_5_11;
    cleanTmpDir = true;
    initrd.luks.devices = {
      crootfs = { device = "/dev/nvme0n1p1"; preLVM = true; };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;  #needs unfree
    opengl.enable = true;
##    opengl.driSupport32Bit = true; #
  };

  powerManagement = {
    enable = true;
  };

  security = {
    pam.enableSSHAgentAuth = true;
    wrappers."mount.cifs".source = "${pkgs.cifs-utils}/bin/mount.cifs";
  };

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  networking = {
    hostName = "kalamos";
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

  environment.pathsToLink = [ "/" ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}
