{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [
      ../../common.nix

      ./settings.nix
      ./backup.nix
      ./bind.nix
      ./nginx.nix
      ./email.nix
      ./ejabberd.nix
      ./gitblit.nix
      ./sitebag.nix
      ./myperception.nix
      ./fotojahn.nix
      ./fetchmail.nix
      ./shelter.nix
    ];

  settings.primaryIp = "10.0.2.15";
  settings.primaryDomain = "testvm.com";

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
    };
    kernelPackages = pkgs.linuxPackages_4_3;
  };

  users.extraUsers = {
    demo = {
      isNormalUser = true;
      description = "Demo user account";
      extraGroups = [ "wheel" "audio" "messagebus" "systemd-journal" ];
      password = "demo";
      uid = 1004;
    };
  };

  networking = {
    hostName = "skyrostest";
    localCommands = ''
      ip addr add 10.0.2.15/24 dev eth0
      ip link set dev eth0 up
      ip route add default via 10.0.2.1
      echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
    '';
  };

  services.logrotate = {
    enable = true;
    config = ''
      compress
    '';
  };

  services.ejabberd15 = {
    enable = true;
  };

  services.sitebag.enable = true;

  services.myperception = {
    enable = true;
    bindPort = 10100;
  };

  services.fotojahn = {
    enable = true;
    bindPort = 10200;
  };

  services.fetchmail = {
    enable = true;
  };

  hardware = {
    #cpu.intel.updateMicrocode = true;  #needs unfree
  };

}
