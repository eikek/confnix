{ config, lib, pkgs, ... }:
let
 serverpass = if (builtins.tryEval <serverpass>).success then
   builtins.readFile <serverpass>
   else builtins.throw ''Please specify a file that contains the
     password to mount the fileserver and add it to the NIX_PATH
     variable with key "serverpass".
   '' ;
  hinpass = let val = builtins.tryEval <hinpass>; in
   if (val.success) then builtins.toPath val.value
   else builtins.throw ''Please specify a file that contains the
     password to mount the fileserver and add it to the NIX_PATH
     variable with key "hinpass".
  '' ;
  fileServer = "bluecare-s54";
in
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
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices = [
      { device = "/dev/sda4"; name = "crootfs"; preLVM = true; }
    ];
    cleanTmpDir = true;
  };

  system.stateVersion = "18.09";

  users.groups.kvm = {
    members = [ "eike" ];
  };
  users.groups.docker = {
    members = [ "eike" ];
  };

  services.openssh = {
   enable = true;
   forwardX11 = true;
  };

  services.webact = {
    enable = true;
    userService = true;
    baseDir = "/home/eike/webact";
    extraPackages = [ pkgs.bash pkgs.ammonite pkgs.coreutils ];
    extraPaths = [ "/home/eike/bin" ];
    extraEnv = {
      "DISPLAY" = ":0";
    };
    bindHost = "localhost";
  };

  services.ntp = {
    servers = [ "192.168.10.1" ];
  };

  services.openvpn.servers = {
    officeVPN = { config = " config /root/openvpn/vpfwblue.bluecare.ch.ovpn "; };
  };

  # needed for the `user` option below
  security.wrappers."mount.cifs".source = "${pkgs.cifs-utils}/bin/mount.cifs";

  fileSystems = {
    "/".device = pkgs.lib.mkForce "/dev/mapper/vg-root";

    "/mnt/fileserver/homes" = {
      device = "//${fileServer}/home";
      fsType = "cifs";
      options = ["user=eik" "password=${serverpass}" "uid=1000" "user" "vers=2.0"];
    };
    "/mnt/fileserver/transfer" = {
      device = "//${fileServer}/Transfer";
      fsType = "cifs";
      options = ["user=eik" "password=${serverpass}" "uid=1000" "user" "vers=2.0"];
    };
    "/mnt/fileserver/data" = {
      device = "//${fileServer}/Data";
      fsType = "cifs";
      options = ["user=eik" "password=${serverpass}" "uid=1000" "user" "vers=2.0"];
    };

    # "/home/music/usb" = {
    #   device = "/dev/disks/by-label/media512";
    #   fsType = "ext4";
    #   options = [ "uid=${toString config.ids.uids.mpd}" "gid=${toString config.ids.gids.mpd}" ];
    # };
  };

  services.acpid.enable = true;
  # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "lock"
  services.logind.lidSwitch = "ignore";

  services.hinclient = {
    enable = true;
    identities = "ekettne1";
    passphrase = hinpass;
    keystore = /root/ekettne1.hin;
    httpProxyPort = 6016;
    clientapiPort = 6017;
    smtpProxyPort = 6018;
    pop3ProxyPort = 6019;
    imapProxyPort = 6020;
  };

  services.xserver = {
    libinput.enable = true;
    displayManager = {
      sessionCommands = ''
        if [ $(${pkgs.xlibs.xrandr}/bin/xrandr --listmonitors --verbose | grep "^[^[:blank:]]" | grep "1920x1200" | wc -l) -eq 2 ]; then
          ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI-0 --mode 1920x1200 --pos 1920x0 \
            --output DisplayPort-1 --mode 1920x1200 --pos 0x0 \
            --output DisplayPort-0 --off \
            --output eDP --off
          ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI-0 --left-of DisplayPort-0
          ${pkgs.xlibs.xrandr}/bin/xrandr --output DisplayPort-0 --rotation left
        fi
      '';
    };

  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 9000 ];
    };
    extraHosts = ''
      127.0.0.1 bluecare-n46 localhost

      192.168.13.27 larnags.int
      192.168.13.28 larnags.int.backend
      192.168.13.75 larnags.sta larnags.sta1
      192.168.13.76 larnags.sta2
      192.168.13.77 larnags.sta.backend larnags.sta.backend1
      192.168.13.78 larnags.sta.backend2
      192.168.13.79 larnags.sta.dbmaster
      192.168.13.80 larnags.sta.dbslave1
      192.168.13.81 larnags.sta.dbslave2
      192.168.13.71 patstamm.int patstamm.int1
      192.168.13.72 patstamm.int2
      192.168.13.83 patstamm.sta patstamm.sta1
      192.168.13.88 patstamm.sta2
      192.168.13.73 zrla.sta
      192.168.13.85 zrc.sta
    '';
    hostName = "bluecare-n46";
    wireless = {
      enable = true;
    };
    useDHCP = true;

    # enable networking in qemu vms
    localCommands = ''
     ${pkgs.vde2}/bin/vde_switch -tap tap0 -mod 660 -group kvm -daemon
     ip addr add 10.0.2.1/24 dev tap0
     ip link set dev tap0 up
     ${pkgs.procps}/sbin/sysctl -w net.ipv4.ip_forward=1
     ${pkgs.iptables}/sbin/iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -j MASQUERADE
   '';

    nat = {
      enable = true;
      externalInterface = "ens9";
      internalInterfaces = [ "ve-+" ];
    };

  };

  environment.pathsToLink = [ "/" ];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  nix.maxJobs = lib.mkOverride 20 4;

  nixpkgs.config = {
    allowUnfree = true;
  };

  # refer to the osx manual here https://intranet/x/EQNxAg
  services.printing = {
    drivers = [ pkgs.utaxccdclp ];
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/music";
    extraConfig = ''
      max_connections "15"
      audio_output {
        type "alsa"
        name "FIIO X5"
        device "iec958:CARD=X5,DEV=0"
      }
    '';
  };
  services.mpc4s = {
    enable = true;
    userService = true;
    musicDirectory = "/home/music";
    mpdConfigs = {
      default = {
        host = "127.0.0.1";
        port = 6600;
        max-connections = 10;
        title = "BC46";
      };
    };
    coverThumbDir = "/home/eike/.mpd/thumbnails";
    bindHost = "localhost";
    bindPort = 9600;
  };

  fonts.fonts = with pkgs; [
    corefonts #unfree
  ];

  environment.systemPackages = with pkgs; [
    tesseract_4
    mongodb
    mongodb-tools
    ansible
    nodePackages.grunt-cli
    nodePackages.gulp
    yarn
    vagrant
#    libreoffice
#    wpsoffice
    subversion
    slack
    peek
    mpc_cli
    ncmpc
    ncmpcpp
  ];

  users.extraUsers.lansweeper = let
    key = if (builtins.pathExists ./id_lansweeper.pub) then builtins.readFile ./id_lansweeper.pub
          else throw "No public key file for lansweeper";
  in {
    isSystemUser = true;
    home = "/var/lib/lansweeper";
    createHome = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ key ];
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;  #needs unfree
    opengl.driSupport32Bit = true;
  };
}
