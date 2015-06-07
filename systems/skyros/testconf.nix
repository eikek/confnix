{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ ./hw-skyros.nix
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


  settings.primaryDomain = "testvm.com";

  boot.loader.grub.devices = [ "/dev/sda" ];

  networking = {
    hostName = "skyrostest";
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
