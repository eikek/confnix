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
      enable = false;
    };
    useDHCP = true;
    wicd.enable = true;

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

  services.postgresql = {
    enable = true;
  };

  environment.pathsToLink = [ "/" ];

  system.activationScripts = {
    kworkerbug = ''
      echo "disable" > /sys/firmware/acpi/interrupts/gpe6F
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
