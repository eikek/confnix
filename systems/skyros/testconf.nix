{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ ./hw-eknet.nix
      ../../common.nix

      ./settings.nix
      ./bind.nix
      ./nginx.nix
      ./email.nix
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
