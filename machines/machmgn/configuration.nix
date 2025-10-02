{ config, pkgs, ... }:
let
  sshkeys = import ../../secrets/ssh-keys.nix;
  usermod = import ../../modules/user.nix { username = "eike"; };
in
{
  imports = [
    ./hw-machmgn.nix
    ./java.nix
    ./tinyproxy.nix
    ./wireguard.nix
    ../../modules/flakes.nix
    ../../modules/packages.nix
    usermod
  ];

  age.secrets.eike.file = ../../secrets/eike.age;
  users.users.eike.hashedPasswordFile = config.age.secrets.eike.path;

  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "machmgn";
    useDHCP = true;
    firewall.allowedTCPPorts = [ 21301 ];
  };

  services.udisks2 = { enable = true; };

  services.openssh = {
    enable = true;
    ports = [ 22 21301 ];
    settings.X11Forwarding = true;
  };

  environment.systemPackages = [ pkgs.noip pkgs.tcpdump ];

  system.stateVersion = "25.05";

}
