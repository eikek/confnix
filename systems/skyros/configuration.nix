{ config, pkgs, lib, ... }:
with config;
{
  imports =
    [ ./hw-skyros.nix
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

  boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" ];

  services.openssh.passwordAuthentication = false;

  networking = {
    hostName = "skyros";

    defaultMailServer = {
      domain = settings.primaryDomain;
      hostName = "localhost";
      root = "root@" + settings.primaryDomain;
    };

    firewall = {
      allowedTCPPorts = [ 22 25 587 143 80 443 29418 ];
      allowedUDPPorts = [ 53 ];
    };
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

  time.timeZone = "UTC";

  services.sitebag.enable = true;

  users.extraGroups = lib.singleton {
    name = "publet";
    gid = config.ids.gids.publet;
  };
  users.extraUsers = lib.singleton {
    name = "publet";
    uid = config.ids.uids.publet;
    extraGroups = ["publet"];
    description = "Publet daemon user.";
  };
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

  system.activationScripts = {
    datachmod = ''
      mkdir -p /var/data
      chmod 755 /var/data
    '';
  };

  environment.systemPackages = with pkgs; [
    goaccess
    fetchmail
    leiningen
    scala
    jdk
    clojure
    mailutils
  ];
}
