{ config, pkgs, ... }:

{

  users.extraGroups.vboxusers.members = [ "eike" ];
  virtualisation.virtualbox.host.enable = true;
}
