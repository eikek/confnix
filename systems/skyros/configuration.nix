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
      ./ejabberd.nix
      ./email.nix
      ./gitea.nix
      ./sitebag.nix
      ./myperception.nix
      ./fotojahn.nix
      ./fetchmail.nix
      ./shelter.nix
      ./sharry.nix
      ./sharrydemo.nix
    ];


  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" ];
    };
    kernelPackages = pkgs.linuxPackages_4_8;
  };

  networking = {
    hostName = "skyros";
  };

  settings.primaryIp = "188.40.107.134";
  settings.forwardNameServers = [
   "213.133.98.98"
   "213.133.99.99"
   "213.133.100.100"
  ];
  settings.useCertificate = true;
  settings.certificate = "/etc/nixos/certs/certificate.crt";
  settings.certificateKey = "/etc/nixos/certs/certificate_key.key";
  settings.caCertificate = "/etc/nixos/certs/ca_cert.crt";

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
    cpu.intel.updateMicrocode = true;  #needs unfree
  };

}
