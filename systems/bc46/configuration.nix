{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hw-bc46.nix
      ../../common-desktop.nix
      ../../env-vbox.nix
    ];

  boot = {
    loader = {
      timeout = 10;
      #gummiboot.enable = true;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices = [
      { device = "/dev/sda4"; name = "crootfs"; preLVM = true; }
    ];
  };

  users.groups.kvm = {
    members = [ "eike" ];
  };

  services.ntp = {
    servers = [ "192.168.10.1" ];
  };

  # needed for the `user` option below
  security.setuidPrograms = [ "mount.cifs" ];

  fileSystems = let
   serverpass = if (builtins.tryEval <serverpass>).success then
     builtins.readFile <serverpass>
     else builtins.throw ''Please specify a file that contains the
       password to mount the fileserver and add it to the NIX_PATH
       variable with key "serverpass".
     '' ;
  in {
    "/".device = pkgs.lib.mkForce "/dev/mapper/vg-root";

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
  };

  services.xserver = {
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      accelFactor = "0.001";
      buttonsMap = [ 1 3 2 ];
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 9000 ];
    };
    extraHosts = ''
      127.0.0.1 macnix bluecare-n46

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
    hostName = "bluecare-n46";
    wireless = {
      enable = false;
    };
    useDHCP = true;
    wicd.enable = true;

    # enable networking in qemu vms
    localCommands = ''
     ${pkgs.vde2}/bin/vde_switch -tap tap0 -mod 660 -group kvm -daemon
     ip addr add 10.0.2.1/24 dev tap0
     ip link set dev tap0 up
     ${pkgs.procps}/sbin/sysctl -w net.ipv4.ip_forward=1
     ${pkgs.iptables}/sbin/iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -j MASQUERADE
   '';
  };

  environment.pathsToLink = [ "/" ];

  nixpkgs.config = {
    allowUnfree = true;
    firefox = {
      enableAdobeFlash = true;
    };
  };

  fonts.fonts = with pkgs; [
    corefonts #unfree
  ];

  environment.systemPackages = with pkgs; [
    tesseract304
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
