{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-macnix.nix
      ../../common-desktop.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" ];
    };
  };

  virtualisation.virtualbox.guest.enable = true;

  services.xserver = {
    displayManager = {
      sessionCommands = ''
#        ${pkgs.xlibs.xrandr}/bin/xrandr --output VGA-1 --mode 1440x900 --pos 0x0 --output VGA-0 --mode 1920x1200 --pos 1440x0
      '';
    };
  };

  services.ntp = {
    servers = [ "192.168.10.1" ];
  };

  systemd.timers.clocksync = {
    description = "Every 5 minutes.";
    enable = true;
    timerConfig = {
      OnCalendar = "*:0/5";
    };
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services.clocksync = {
    enable = true;
    wantedBy = ["multi-user.target"];
    script = "${pkgs.utillinux}/bin/hwclock --hctosys";
  };

  fileSystems = let
   serverpass = if (builtins.tryEval <serverpass>).success then
     builtins.readFile <serverpass>
     else builtins.throw ''Please specify a file that contains the
       password to mount the fileserver and add it to the NIX_PATH
       variable with key "serverpass".
     '' ;
  in {
    "/mnt/fileserver/homes" = {
      device = "//bluecare-s22.bluecare.local/home";
      fsType = "cifs";
      options = ["user=eik" "password=${serverpass}" "uid=1000" "user"];
    };
    "/mnt/fileserver/transfer" = {
      device = "//bluecare-s22.bluecare.local/Transfer";
      fsType = "cifs";
      options = ["user=eik" "password=${serverpass}" "uid=1000" "user"];
    };
    "/mnt/fileserver/data" = {
      device = "//bluecare-s22.bluecare.local/Data";
      fsType = "cifs";
      options = ["user=eik" "password=${serverpass}" "uid=1000" "user"];
    };
    "/home/host" = {
      device = "home";
      fsType = "vboxsf";
      options = ["auto" "rw" "uid=1000" "gid=100" "exec"];
      noCheck = true;
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 9000 ];
    };
    extraHosts = ''
      127.0.0.1 macnix bluecare-n46_1

      # https://intranet/x/HIGkAQ
      192.168.13.27 larnags.int
      192.168.13.28 larnags.int.backend
      192.168.13.73 larnags.hii
      192.168.13.75 larnags.sta larnags.sta1
      192.168.13.76 larnags.sta2
      192.168.13.77 larnags.sta.backend larnags.sta.backend1
      192.168.13.78 larnags.sta.backend2
      192.168.13.79 larnags.sta.dbmaster
      192.168.13.80 larnags.sta.dbslave1
      192.168.13.81 larnags.sta.dbslave2
    '';
    hostName = "bluecare-n46_1";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = false;
  };

  environment.pathsToLink = [ "/" ];

  environment.systemPackages = with pkgs; [
    tesseract
    mongodb
    mongodb-tools
    ansible2
    nodePackages.grunt-cli
  ];

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };
}
