{ config, pkgs, ... }:
let mykey = builtins.readFile /home/eike/.ssh/id_rsa.pub; in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-ithaka.nix
      ../../common-desktop.nix
      ../../env-home.nix
      ../../env-vbox.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" ];
    };
    # this should not be necessary, but my system did not start x otherwise
    initrd.kernelModules = [ "nouveau" ];
    blacklistedKernelModules = [ "snd-hda-intel" ];
  };

  fonts.fontconfig = {
    dpi = 140;
  };

  users.groups.kvm = {
    members = [ "eike" ];
  };

  networking = {
    hostName = "ithaka";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;

    nat = {
      enable = true;
      externalInterface = "enp5s0";
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

  services.xserver = {
    videoDrivers = [ "nouveau" ];
    monitorSection = ''
      DisplaySize 698 393
    '';
    displayManager = {
      sessionCommands = ''
        xrandr --dpi 140
      '';
    };
  };

  services.postgresql = {
    enable = true;
    extraConfig = ''
      track_activities = true
      shared_buffers = 2GB
      maintenance_work_mem = 2GB
      work_mem = 16MB
      fsync = off
      synchronous_commit = off
      wal_level = minimal
      full_page_writes = off
      wal_buffers = 64MB
      max_wal_senders = 0
      wal_keep_segments = 0
      archive_mode = off
      autovacuum = off
      log_statement = all
    '';
  };

  environment.pathsToLink = [ "/" ];

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
