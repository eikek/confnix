{ config, pkgs, nixpkgs, dsc, ... }:
let
  sshkeys = import ../../secrets/ssh-keys.nix;
  printer = import ../../modules/printer.nix;
  usermod = import ../../modules/user.nix { username = "eike"; };
  dockermod = import ../../modules/docker.nix [ "eike" ];
in
{
  # note: one of monitor-int or monitor-ext modules is required
  imports = [
    ./hw-kalamos.nix
    ../../modules/bluetooth.nix
    ../../modules/emacs.nix
    ../../modules/flakes.nix
    ../../modules/fonts.nix
    ../../modules/ids.nix
    ../../modules/java.nix
    ../../modules/packages.nix
    ../../modules/region-neo.nix
    ./immich.nix
    ./postgres.nix
    ./wireguard.nix
    ./ventoux.nix
    usermod
    dockermod
  ] ++ (import ../../pkgs/modules.nix);

  age.secrets.eike.file = ../../secrets/eike.age;
  users.users.eike.hashedPasswordFile = config.age.secrets.eike.path;

  boot = {
    tmp.cleanOnBoot = true;
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

  fileSystems = {
    "/mnt/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
      options = [ "auto" "user" "rw" "exec" "suid" "async" ];
      noCheck = true;
    };
  };

  i18n.defaultLocale = pkgs.lib.mkForce "de_DE.UTF-8";

  #Requires recompile of virtualbox
  #  virtualisation.virtualbox.host.enableExtensionPack = true;

  security = {
    pam.sshAgentAuth.enable = true;
    wrappers = {
      "mount.cifs" = {
        source = "${pkgs.cifs-utils.bin}/bin/mount.cifs";
        owner = "root";
        group = "root";
      };
    };
  };

  services.locate = {
    enable = true;
    interval = "13:00";
  };

  services.atd = {
    enable = true;
  };

  users.groups.kvm = { members = [ "eike" ]; };

  networking = {
    hostName = "kalamos";
    wireless = { enable = true; };
    useDHCP = true;
  };

  # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "lock"
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  services.udisks2 = { enable = true; };

  environment.systemPackages = with pkgs; [
    ffmpeg
    flac
    mediainfo
    mpv
    fzf
  ];

  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  nix = {
    sshServe.enable = true;
    sshServe.keys = [ sshkeys.eike ];
  };

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true; # needs unfree
    graphics.enable32Bit = true;
  };

  system.stateVersion = "26.05";
}
