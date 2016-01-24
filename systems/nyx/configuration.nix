{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-nyx.nix
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
    initrd.luks.devices = [
      {device = "/dev/sda5"; name = "rootfs"; }
    ];
  };

  networking = {
    hostName = "nyx";
    wireless = {
      enable = false;  # would enable wpa_supplicant. not needed with wicd
      userControlled.enable = true;
      interfaces = [ "wlp2s0" ];
    };

    useDHCP = true;
    wicd.enable = true;

    nat = {
      enable = true;
      externalInterface = "wlp2s0";
      internalInterfaces = [ "ve-+" ];
    };
  };

  services.acpid.enable = true;
  services.sitebag.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    videoDrivers = [ "intel" ];
  };

  environment.pathsToLink = [ "/" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql95;
    extraConfig = ''
      track_activities = true
      fsync = off
      synchronous_commit = off
      wal_level = minimal
      full_page_writes = off
      wal_buffers = 64MB
      max_wal_senders = 0
      wal_keep_segments = 0
      archive_mode = off
      autovacuum = off
    '';
  };

  environment.systemPackages = with pkgs ; [
    pgadmin
  ];


  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };

}
