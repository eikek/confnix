{ config, pkgs, ... }:
let
  sshkeys = import ../../secrets/ssh-keys.nix;
in

{
  users.users.ventoux = {
    name = "ventoux";
    isNormalUser = true;
    uid = 1002;
    createHome = true;
    home = "/home/ventoux";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys =
      if builtins.hasAttr "eike" sshkeys then [ sshkeys.eike ] else [ ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 8888 ];
  };
}
